import assert from 'node:assert/strict';
import { once } from 'node:events';
import { spawn } from 'node:child_process';
import { existsSync } from 'node:fs';
import { mkdtemp, readFile, rm, writeFile } from 'node:fs/promises';
import http from 'node:http';
import net from 'node:net';
import os from 'node:os';
import path from 'node:path';

const node = process.execPath;
const relay = new URL('./edge-ai-relay.mjs', import.meta.url).pathname;
const tempDir = await mkdtemp(path.join(os.tmpdir(), 'edge-ai-relay-test-'));
const firstId = '12345678-1234-1234-1234-123456789abc';
const secondId = 'abcdef12-1234-1234-1234-123456789abc';
const thirdId = '01234567-1234-1234-1234-123456789abc';
const fourthId = 'fedcba98-1234-1234-1234-123456789abc';
const endpoints = [firstId, secondId, thirdId, fourthId].map((id) => `ws://127.0.0.1:9223/devtools/browser/${id}`);
let windowsServer;

function fakePowerShellSource() {
  return `#!${node}
const { appendFileSync, existsSync, readFileSync } = require('node:fs');
const { spawn } = require('node:child_process');
const source = Buffer.from(process.argv[process.argv.indexOf('-EncodedCommand') + 1], 'base64').toString('utf16le');
if (source.includes('STARTUP')) {
  if (process.env.TEST_STARTUP_MODE === 'fail') { process.exit(1); }
  else if (process.env.TEST_STARTUP_MODE === 'hang') { setInterval(() => {}, 60_000); }
  else {
    const count = existsSync(process.env.TEST_STARTUP_COUNTER) ? readFileSync(process.env.TEST_STARTUP_COUNTER, 'utf8').length : 0;
    appendFileSync(process.env.TEST_STARTUP_COUNTER, 's');
    process.stdout.write(process.env.TEST_ENDPOINTS.split(',')[count] + '\\r\\n');
    process.exit(0);
  }
}
appendFileSync(process.env.TEST_RELAY_COUNTER, 'r');
if (process.env.TEST_RELAY_MODE === 'stall') {
  process.once('SIGTERM', () => { appendFileSync(process.env.TEST_RELAY_EXIT_COUNTER, 'x'); process.exit(0); });
  process.stdin.once('data', () => {
    process.stdout.write('HTTP/1.1 101 Switching Protocols\\r\\nConnection: Upgrade\\r\\nUpgrade: websocket\\r\\n\\r\\n');
    process.stdin.resume();
  });
  setInterval(() => {}, 60_000);
} else {
  const child = spawn(process.execPath, [process.env.TEST_RELAY]);
  process.stdin.pipe(child.stdin); child.stdout.pipe(process.stdout); child.stderr.pipe(process.stderr);
  child.on('close', (code) => process.exit(code ?? 1));
}
`;
}

function fakeRelaySource() {
  return `
const net = require('node:net');
const client = net.connect(Number(process.env.TEST_PORT), '127.0.0.1');
process.stdin.pipe(client); client.pipe(process.stdout);
client.on('error', () => process.exit(1)); client.on('end', () => process.exit(0));
`;
}

function fakeNpxSource() {
  return `#!${node}
const { writeFileSync } = require('node:fs');
const http = require('node:http'); const net = require('node:net');
const browserUrl = new URL(process.argv.find((argument) => argument.startsWith('--browser-url=')).slice('--browser-url='.length));
const write = (value) => process.stdout.write(value + '\\n');
const get = (path, headers = {}) => new Promise((resolve, reject) => {
  const request = http.get({ host: browserUrl.hostname, port: browserUrl.port, path, headers }, (response) => {
    let body = ''; response.setEncoding('utf8'); response.on('data', (chunk) => { body += chunk; }); response.on('end', () => resolve({ status: response.statusCode, body }));
  }); request.on('error', reject);
});
const upgrade = (path, head, holdMs = 0) => new Promise((resolve, reject) => {
  const socket = net.connect(Number(browserUrl.port), browserUrl.hostname, () => {
    const request = Buffer.concat([Buffer.from('GET ' + path + ' HTTP/1.1\\r\\nHost: ' + browserUrl.host + '\\r\\nConnection: Upgrade\\r\\nUpgrade: websocket\\r\\n\\r\\n'), head]);
    if (holdMs) { socket.write(request); setTimeout(() => socket.end(), holdMs); } else { socket.end(request); }
  });
  const chunks = []; socket.on('data', (chunk) => chunks.push(chunk)); socket.on('end', () => resolve(Buffer.concat(chunks))); socket.on('error', reject);
});
(async () => {
  write('catalog-no-discovery');
  if (process.env.TEST_NPX_MODE === 'catalog') process.exit(0);
  if (process.env.TEST_NPX_MODE === 'exit') process.exit(7);
  if (process.env.TEST_NPX_MODE === 'hold') {
    const version = await get('/json/version'); const endpoint = new URL(JSON.parse(version.body).webSocketDebuggerUrl);
    const socket = net.connect(Number(endpoint.port), endpoint.hostname, () => socket.write('GET ' + endpoint.pathname + ' HTTP/1.1\\r\\nHost: ' + endpoint.host + '\\r\\nConnection: Upgrade\\r\\nUpgrade: websocket\\r\\n\\r\\n'));
    socket.once('data', () => { writeFileSync(process.env.TEST_HOLD_READY, 'ready'); });
    setInterval(() => {}, 60_000); return;
  }
  if (process.env.TEST_NPX_MODE === 'expect-503') {
    const failed = await get('/json/version'); if (failed.status !== 503) process.exit(9); write('discovery-503-ok'); process.exit(0);
  }
  if (process.env.TEST_NPX_MODE === 'drain-deadline') {
    const version = await get('/json/version'); const endpoint = new URL(JSON.parse(version.body).webSocketDebuggerUrl);
    const startedAt = Date.now();
    await new Promise((resolve, reject) => {
      const socket = net.connect(Number(endpoint.port), endpoint.hostname, () => socket.write('GET ' + endpoint.pathname + ' HTTP/1.1\\r\\nHost: ' + endpoint.host + '\\r\\nConnection: Upgrade\\r\\nUpgrade: websocket\\r\\n\\r\\n'));
      socket.once('data', () => { socket.end(); resolve(); }); socket.once('error', reject);
    });
    const deadline = Date.now() + 8_000;
    while (!require('node:fs').existsSync(process.env.TEST_RELAY_EXIT_COUNTER) && Date.now() < deadline) await new Promise((resolve) => setTimeout(resolve, 20));
    const elapsed = Date.now() - startedAt;
    if (!require('node:fs').existsSync(process.env.TEST_RELAY_EXIT_COUNTER) || elapsed < 5_000 || elapsed > 8_500) process.exit(19);
    write('drain-deadline-ok'); process.exit(0);
  }
  const noEndpoint = await upgrade('/devtools/browser/${firstId}', Buffer.alloc(0));
  if (!noEndpoint.toString('ascii').startsWith('HTTP/1.1 404')) process.exit(10);
  const [firstResponse, sameResponse] = await Promise.all([get('/json/version'), get('/json/version')]);
  if (firstResponse.status !== 200 || sameResponse.status !== 200) process.exit(11);
  const first = JSON.parse(firstResponse.body).webSocketDebuggerUrl;
  if (first !== JSON.parse(sameResponse.body).webSocketDebuggerUrl) process.exit(12);
  const unknown = await get('/other'); if (unknown.status !== 404) process.exit(13);
  const forbidden = await get('/json/version', { Host: 'localhost:' + browserUrl.port }); if (forbidden.status !== 403) process.exit(14);
  const wrongPath = await upgrade('/devtools/browser/${secondId}', Buffer.alloc(0)); if (!wrongPath.toString('ascii').startsWith('HTTP/1.1 404')) process.exit(15);
  const opaque = Buffer.from([0, 255, 65, 0, 0xe4, 0xb8, 0xad]);
  const echoed = await upgrade(new URL(first).pathname, opaque, 9000);
  if (!echoed.includes(opaque)) process.exit(16);
  const fresh = await get('/json/version'); if (fresh.status !== 200 || JSON.parse(fresh.body).webSocketDebuggerUrl === first) process.exit(17);
  write('synthetic-mcp-ok');
})().catch(() => process.exit(18));
`;
}

function listenWindowsServer() {
  return new Promise((resolve) => {
    const server = net.createServer((socket) => socket.pipe(socket));
    server.listen({ host: '127.0.0.1', port: 0 }, () => resolve(server));
  });
}

async function run(args, environment = {}, { signalOnFile, timeoutMs = 15_000 } = {}) {
  const child = spawn(node, [relay, ...args], { env: { ...process.env, ...environment }, stdio: ['pipe', 'pipe', 'pipe'] });
  let stdout = ''; let stderr = '';
  child.stdout.setEncoding('utf8'); child.stderr.setEncoding('utf8');
  child.stdout.on('data', (chunk) => { stdout += chunk; }); child.stderr.on('data', (chunk) => { stderr += chunk; });
  const timeout = setTimeout(() => child.kill('SIGKILL'), timeoutMs);
  if (signalOnFile) {
    const deadline = Date.now() + 5_000;
    while (!existsSync(signalOnFile) && Date.now() < deadline) await new Promise((resolve) => setTimeout(resolve, 20));
    assert.ok(existsSync(signalOnFile), 'hold flow did not become active');
    child.kill('SIGTERM');
  }
  const [code] = await once(child, 'close');
  clearTimeout(timeout);
  return { code, stdout, stderr };
}

try {
  const fakePowerShell = path.join(tempDir, 'fake-powershell.cjs');
  const fakeRelay = path.join(tempDir, 'fake-relay.cjs');
  const fakeNpx = path.join(tempDir, 'npx');
  const startup = path.join(tempDir, 'startup.ps1');
  const relayPs = path.join(tempDir, 'relay.ps1');
  const startupCounter = path.join(tempDir, 'startup-counter');
  const relayCounter = path.join(tempDir, 'relay-counter');
  const relayExitCounter = path.join(tempDir, 'relay-exit-counter');
  const holdReady = path.join(tempDir, 'hold-ready');
  await Promise.all([
    writeFile(fakePowerShell, fakePowerShellSource(), { mode: 0o755 }), writeFile(fakeRelay, fakeRelaySource()),
    writeFile(fakeNpx, fakeNpxSource(), { mode: 0o755 }), writeFile(startup, 'STARTUP'), writeFile(relayPs, 'RELAY'),
  ]);
  windowsServer = await listenWindowsServer();
  const address = windowsServer.address(); assert.ok(address && typeof address !== 'string');
  const environment = {
    TEST_ENDPOINTS: endpoints.join(','), TEST_RELAY: fakeRelay, TEST_PORT: String(address.port),
    TEST_STARTUP_COUNTER: startupCounter, TEST_RELAY_COUNTER: relayCounter, TEST_RELAY_EXIT_COUNTER: relayExitCounter, TEST_HOLD_READY: holdReady,
    PATH: `${tempDir}:${process.env.PATH}`,
  };
  const catalog = await run([fakePowerShell, startup, relayPs, '--no-usage-statistics'], { ...environment, TEST_NPX_MODE: 'catalog' });
  assert.equal(catalog.code, 0, catalog.stderr); assert.equal(catalog.stdout, 'catalog-no-discovery\n'); assert.equal(existsSync(startupCounter), false);
  const success = await run([fakePowerShell, startup, relayPs, '--no-usage-statistics'], environment);
  assert.equal(success.code, 0, success.stderr); assert.deepEqual(success.stdout.split('\n').filter(Boolean), ['catalog-no-discovery', 'synthetic-mcp-ok']);
  assert.equal(await readFile(startupCounter, 'utf8'), 'ss'); assert.equal(await readFile(relayCounter, 'utf8'), 'r');
  const discoveryFailure = await run([fakePowerShell, startup, relayPs, '--no-usage-statistics'], { ...environment, TEST_NPX_MODE: 'expect-503', TEST_STARTUP_MODE: 'fail' });
  assert.equal(discoveryFailure.code, 0, discoveryFailure.stderr); assert.match(discoveryFailure.stdout, /discovery-503-ok/);
  const childExit = await run([fakePowerShell, startup, relayPs, '--no-usage-statistics'], { ...environment, TEST_NPX_MODE: 'exit' });
  assert.equal(childExit.code, 1); assert.match(childExit.stderr, /chrome-devtools-mcp exited \(code=7/);
  const hold = await run([fakePowerShell, startup, relayPs, '--no-usage-statistics'], { ...environment, TEST_NPX_MODE: 'hold' }, { signalOnFile: holdReady });
  assert.equal(hold.code, 143, hold.stderr);
  const drainDeadline = await run([fakePowerShell, startup, relayPs, '--no-usage-statistics'], { ...environment, TEST_NPX_MODE: 'drain-deadline', TEST_RELAY_MODE: 'stall' });
  assert.equal(drainDeadline.code, 0, drainDeadline.stderr); assert.match(drainDeadline.stdout, /drain-deadline-ok/);
  assert.equal(await readFile(relayExitCounter, 'utf8'), 'x');
  const invalidArgument = await run([fakePowerShell, startup, relayPs, '--ws-endpoint=ws://bad'], environment);
  assert.equal(invalidArgument.code, 1); assert.match(invalidArgument.stderr, /only --no-usage-statistics/);
  process.stdout.write('edge-ai-relay synthetic tests: PASS (7 cases)\n');
} finally {
  if (windowsServer?.listening) await new Promise((resolve) => windowsServer.close(resolve));
  await rm(tempDir, { recursive: true, force: true });
}
