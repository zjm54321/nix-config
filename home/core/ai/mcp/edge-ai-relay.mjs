import { spawn } from 'node:child_process';
import { readFile } from 'node:fs/promises';
import http from 'node:http';

const MAX_CONNECTIONS = 8;
const STARTUP_TIMEOUT_MS = 15_000;
const FLOW_START_TIMEOUT_MS = 8_000;
const FLOW_DRAIN_GRACE_MS = 6_000;
const TERMINATE_GRACE_MS = 2_000;
const CAPTURE_MAX_BYTES = 64 * 1024;
const ALLOWED_MCP_ARGUMENT = '--no-usage-statistics';
const WS_ENDPOINT_PATTERN = /^ws:\/\/127\.0\.0\.1:9223\/devtools\/browser\/[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}$/i;

function fail(message) {
  throw new Error(message);
}

function encodePowerShell(source) {
  return Buffer.from(source, 'utf16le').toString('base64');
}

function sanitizeLog(value) {
  return value.replace(/[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}/gi, '<redacted-browser-id>');
}

function validateMcpArguments(args) {
  if (args.length !== 1 || args[0] !== ALLOWED_MCP_ARGUMENT) {
    fail(`only ${ALLOWED_MCP_ARGUMENT} may be passed to chrome-devtools-mcp`);
  }
}

function terminateChild(child) {
  if (!child || child.exitCode !== null || child.signalCode !== null) return;
  child.kill('SIGTERM');
  const forceTimer = setTimeout(() => child.kill('SIGKILL'), TERMINATE_GRACE_MS);
  child.once('close', () => clearTimeout(forceTimer));
}

function runPowerShell(powerShell, source, timeoutMs, label, onSpawn) {
  return new Promise((resolve, reject) => {
    const child = spawn(powerShell, [
      '-NoLogo',
      '-NoProfile',
      '-NonInteractive',
      '-EncodedCommand',
      encodePowerShell(source),
    ], { stdio: ['ignore', 'pipe', 'pipe'] });
    onSpawn(child);
    const stdout = [];
    let stdoutBytes = 0;
    let stderr = '';
    let stderrBytes = 0;
    let stdoutTooLarge = false;
    let timedOut = false;
    const timeout = setTimeout(() => {
      timedOut = true;
      terminateChild(child);
    }, timeoutMs);
    child.stdout.on('data', (chunk) => {
      stdoutBytes += chunk.length;
      if (stdoutBytes > CAPTURE_MAX_BYTES) {
        stdoutTooLarge = true;
        terminateChild(child);
        return;
      }
      stdout.push(chunk);
    });
    child.stderr.on('data', (chunk) => {
      if (stderrBytes >= CAPTURE_MAX_BYTES) return;
      const remaining = CAPTURE_MAX_BYTES - stderrBytes;
      const kept = chunk.subarray(0, remaining);
      stderrBytes += kept.length;
      const text = sanitizeLog(kept.toString('utf8'));
      stderr += text;
      process.stderr.write(text);
      if (kept.length !== chunk.length) process.stderr.write('edge-ai-relay: PowerShell stderr truncated\n');
    });
    child.on('error', (error) => {
      clearTimeout(timeout);
      reject(new Error(`${label} could not start: ${error.message}`));
    });
    child.on('close', (code, signal) => {
      clearTimeout(timeout);
      if (stdoutTooLarge) {
        reject(new Error(`${label} stdout exceeded ${CAPTURE_MAX_BYTES} bytes`));
      } else if (timedOut) {
        reject(new Error(`${label} timed out after ${timeoutMs}ms`));
      } else if (code !== 0) {
        reject(new Error(`${label} failed (code=${code}, signal=${signal ?? 'none'}): ${stderr.trim() || 'no error output'}`));
      } else {
        resolve(Buffer.concat(stdout).toString('utf8'));
      }
    });
  });
}

function createRelayChild(powerShell, relayCommand) {
  return spawn(powerShell, [
    '-NoLogo',
    '-NoProfile',
    '-NonInteractive',
    '-EncodedCommand',
    relayCommand,
  ], { stdio: ['pipe', 'pipe', 'pipe'] });
}

class RelayFlow {
  constructor(socket, powerShell, relayCommand, initialBytes, onClose) {
    this.socket = socket;
    this.child = createRelayChild(powerShell, relayCommand);
    this.onClose = onClose;
    this.finished = false;
    this.stopping = false;
    this.aborting = false;
    this.socketClosed = false;
    this.childClosed = false;
    this.inputEnded = false;
    this.outputStarted = false;
    this.drainTimer = null;
    this.startTimer = setTimeout(() => {
      if (!this.outputStarted) this.abort(new Error('relay connection did not receive a response in time'));
    }, FLOW_START_TIMEOUT_MS);
    this.writeInput(initialBytes);
    this.attach();
  }

  writeInput(chunk) {
    if (this.inputEnded || this.child.stdin.destroyed) return;
    if (!this.child.stdin.write(chunk)) this.socket.pause();
  }

  attach() {
    const { socket, child } = this;
    socket.on('data', (chunk) => this.writeInput(chunk));
    child.stdin.on('drain', () => socket.resume());
    socket.on('end', () => {
      this.endChildInput();
      this.armDrainDeadline();
    });
    socket.on('error', (error) => this.abort(error));
    socket.on('close', () => {
      this.socketClosed = true;
      this.endChildInput();
      if (!this.stopping && socket.destroyed) this.abort();
      else this.armDrainDeadline();
      this.maybeFinish();
    });
    child.stdin.on('error', (error) => this.abort(error));
    child.stdout.on('data', (chunk) => {
      this.outputStarted = true;
      clearTimeout(this.startTimer);
      if (!socket.destroyed && !socket.write(chunk)) child.stdout.pause();
    });
    socket.on('drain', () => child.stdout.resume());
    child.stdout.on('end', () => {
      if (!socket.destroyed) socket.end();
    });
    child.stdout.on('error', (error) => this.abort(error));
    child.stderr.on('data', (chunk) => process.stderr.write(sanitizeLog(chunk.toString('utf8'))));
    child.on('error', (error) => this.abort(error));
    child.on('close', (code, signal) => {
      this.childClosed = true;
      if (!this.stopping && (code !== 0 || signal !== null)) {
        this.abort(new Error(`Windows relay exited (code=${code}, signal=${signal ?? 'none'})`));
      } else if (!socket.destroyed) {
        socket.end();
      }
      this.maybeFinish();
    });
  }

  endChildInput() {
    if (this.inputEnded) return;
    this.inputEnded = true;
    this.child.stdin.end();
  }

  armDrainDeadline() {
    if (this.finished || this.drainTimer) return;
    this.drainTimer = setTimeout(() => {
      this.abort(new Error('relay connection did not finish draining in time'));
    }, FLOW_DRAIN_GRACE_MS);
  }

  shutdown() {
    if (this.finished || this.stopping) return;
    this.stopping = true;
    this.endChildInput();
    this.socket.end();
    this.armDrainDeadline();
  }

  abort(error) {
    if (this.finished || this.aborting) return;
    this.aborting = true;
    clearTimeout(this.startTimer);
    clearTimeout(this.drainTimer);
    if (error) process.stderr.write(`edge-ai-relay: ${sanitizeLog(error.message)}\n`);
    this.socket.destroy();
    this.endChildInput();
    terminateChild(this.child);
    this.maybeFinish();
  }

  maybeFinish() {
    if (this.finished || !this.socketClosed || !this.childClosed) return;
    this.finished = true;
    clearTimeout(this.startTimer);
    clearTimeout(this.drainTimer);
    this.onClose(this);
  }
}

function isExpectedRequest(req, port) {
  return req.headers.host === `127.0.0.1:${port}` && req.headers.origin === undefined;
}

function writeHttpError(response, statusCode) {
  if (response.destroyed || response.writableEnded) return;
  response.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Cache-Control': 'no-store',
    'Content-Length': '2',
  });
  response.end('{}');
}

function rejectUpgrade(socket, statusCode) {
  socket.end(`HTTP/1.1 ${statusCode} ${statusCode === 403 ? 'Forbidden' : 'Not Found'}\r\nConnection: close\r\nContent-Length: 0\r\n\r\n`);
}

function serializeUpgrade(req) {
  const lines = [`${req.method} ${req.url} HTTP/${req.httpVersion}`];
  for (let index = 0; index < req.rawHeaders.length; index += 2) {
    lines.push(`${req.rawHeaders[index]}: ${req.rawHeaders[index + 1]}`);
  }
  return Buffer.from(`${lines.join('\r\n')}\r\n\r\n`, 'latin1');
}

function startRelayServer(powerShell, relayCommand, startupSource) {
  const flows = new Set();
  let discovery = null;
  let discoveryChild = null;
  let latestEndpoint = null;
  const server = http.createServer((req, response) => {
    if (!isExpectedRequest(req, server.address().port)) {
      writeHttpError(response, 403);
      return;
    }
    if (req.method !== 'GET' || req.url !== '/json/version') {
      writeHttpError(response, 404);
      return;
    }
    const getEndpoint = () => {
      if (discovery) return discovery;
      latestEndpoint = null;
      discovery = runPowerShell(
        powerShell,
        startupSource,
        STARTUP_TIMEOUT_MS,
        'dedicated Edge AI startup',
        (child) => { discoveryChild = child; },
      )
        .then((output) => {
          const endpoint = output.replace(/[\r\n]+$/, '');
          if (!WS_ENDPOINT_PATTERN.test(endpoint)) fail('dedicated Edge AI startup returned an invalid CDP endpoint');
          latestEndpoint = endpoint;
          return endpoint;
        });
      discovery.finally(() => {
        discovery = null;
        discoveryChild = null;
      }).catch(() => {});
      return discovery;
    };
    void getEndpoint().then((windowsEndpoint) => {
      const endpoint = new URL(windowsEndpoint);
      const body = Buffer.from(JSON.stringify({ webSocketDebuggerUrl: `ws://127.0.0.1:${server.address().port}${endpoint.pathname}` }));
      if (response.destroyed || response.writableEnded) return;
      response.writeHead(200, {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-store',
        'Content-Length': String(body.length),
      });
      response.end(body);
    }).catch((error) => {
      process.stderr.write(`edge-ai-relay: ${sanitizeLog(error.message)}\n`);
      writeHttpError(response, 503);
    });
  });
  server.on('upgrade', (req, socket, head) => {
    const address = server.address();
    const port = address && typeof address !== 'string' ? address.port : 0;
    if (!isExpectedRequest(req, port)) {
      rejectUpgrade(socket, 403);
      return;
    }
    if (!latestEndpoint || req.method !== 'GET' || req.url !== new URL(latestEndpoint).pathname) {
      rejectUpgrade(socket, 404);
      return;
    }
    if (flows.size >= MAX_CONNECTIONS) {
      rejectUpgrade(socket, 404);
      process.stderr.write('edge-ai-relay: connection limit reached\n');
      return;
    }
    const initialBytes = Buffer.concat([serializeUpgrade(req), head]);
    const flow = new RelayFlow(socket, powerShell, relayCommand, initialBytes, (closedFlow) => flows.delete(closedFlow));
    if (!flow.finished) flows.add(flow);
  });
  server.on('clientError', (_error, socket) => {
    socket.end('HTTP/1.1 400 Bad Request\r\nConnection: close\r\nContent-Length: 0\r\n\r\n');
  });
  return new Promise((resolve, reject) => {
    server.once('error', reject);
    server.listen({ host: '127.0.0.1', port: 0 }, () => {
      server.off('error', reject);
      const address = server.address();
      if (!address || typeof address === 'string' || address.address !== '127.0.0.1' || address.port === 0) {
        server.close();
        reject(new Error('relay did not bind an IPv4 loopback ephemeral port'));
        return;
      }
      resolve({
        server,
        flows,
        port: address.port,
        cancelDiscovery: () => terminateChild(discoveryChild),
      });
    });
  });
}

function terminateMcpGroup(child) {
  if (!child?.pid) return Promise.resolve();
  return new Promise((resolve) => {
    try {
      process.kill(-child.pid, 'SIGTERM');
    } catch {
      resolve();
      return;
    }
    const forceTimer = setTimeout(() => {
      try { process.kill(-child.pid, 'SIGKILL'); } catch { }
    }, TERMINATE_GRACE_MS);
    const finishTimer = setTimeout(resolve, TERMINATE_GRACE_MS * 2);
    child.once('close', () => {
      clearTimeout(forceTimer);
      clearTimeout(finishTimer);
      resolve();
    });
  });
}

async function main() {
  const [powerShell, startupPath, relayPath, ...mcpArguments] = process.argv.slice(2);
  if (!powerShell || !startupPath || !relayPath) fail('internal wrapper arguments are missing');
  validateMcpArguments(mcpArguments);
  const [startupSource, relaySource] = await Promise.all([readFile(startupPath, 'utf8'), readFile(relayPath, 'utf8')]);
  const relay = await startRelayServer(powerShell, encodePowerShell(relaySource), startupSource);
  let mcp;
  let stopping = false;
  let stopPromise;
  let exitCode = 0;
  const stop = (code) => {
    if (stopPromise) return stopPromise;
    stopping = true;
    exitCode = code;
    stopPromise = (async () => {
      const closeServer = new Promise((resolve) => relay.server.close(resolve));
      relay.cancelDiscovery();
      for (const flow of [...relay.flows]) flow.shutdown();
      await Promise.all([closeServer, terminateMcpGroup(mcp)]);
    })();
    return stopPromise;
  };
  relay.server.on('error', (error) => {
    if (!stopping) {
      process.stderr.write(`edge-ai-relay: ${sanitizeLog(error.message)}\n`);
      void stop(1);
    }
  });
  process.once('SIGINT', () => { void stop(130); });
  process.once('SIGTERM', () => { void stop(143); });
  process.stdin.once('end', () => { void stop(0); });
  process.stdin.once('error', () => { void stop(1); });
  try {
    if (stopping) return;
    mcp = spawn('npx', ['-y', 'chrome-devtools-mcp@latest', `--browser-url=http://127.0.0.1:${relay.port}`, ALLOWED_MCP_ARGUMENT], {
      detached: true,
      stdio: ['pipe', 'pipe', 'pipe'],
    });
    mcp.stdin.on('error', (error) => {
      if (!stopping) process.stderr.write(`edge-ai-relay: MCP stdin error: ${error.message}\n`);
    });
    process.stdin.pipe(mcp.stdin);
    mcp.stdout.pipe(process.stdout);
    mcp.stderr.pipe(process.stderr);
    const outcome = await new Promise((resolve, reject) => {
      mcp.once('error', reject);
      mcp.once('close', (code, signal) => resolve({ code, signal }));
    });
    if (!stopping && outcome.code !== 0) fail(`chrome-devtools-mcp exited (code=${outcome.code}, signal=${outcome.signal ?? 'none'})`);
  } catch (error) {
    if (!stopping) {
      exitCode = 1;
      throw error;
    }
  } finally {
    await stop(exitCode);
    process.exitCode = exitCode;
  }
}

main().catch((error) => {
  process.stderr.write(`edge-ai-relay: ${sanitizeLog(error.message)}\n`);
  process.exitCode = 1;
});
