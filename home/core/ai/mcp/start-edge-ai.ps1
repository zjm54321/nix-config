$ErrorActionPreference = 'Stop'

$edgePath = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$profilePath = Join-Path $env:LOCALAPPDATA 'Microsoft\Edge AI\User Data'
$port = 9223

function Fail([string]$message) {
    [Console]::Error.WriteLine("edge-ai: $message")
    exit 1
}

function Get-CdpListeners {
    @(Get-NetTCPConnection -State Listen -LocalPort $port -ErrorAction SilentlyContinue)
}

function Test-AiProcess([object]$process) {
    if ($null -eq $process -or $process.Name -ine 'msedge.exe') {
        return $false
    }

    $commandLine = [string]$process.CommandLine
    $matches = [regex]::Matches($commandLine, '(?i)(?:^|\s)--user-data-dir=(?:"([^"]*)"|([^\s"]+))(?=\s|$)')
    if ($matches.Count -ne 1) {
        return $false
    }

    $actualProfilePath = if ($matches[0].Groups[1].Success) { $matches[0].Groups[1].Value } else { $matches[0].Groups[2].Value }
    return [string]::Equals($actualProfilePath, $profilePath, [StringComparison]::OrdinalIgnoreCase)
}

function Confirm-AiEndpoint([array]$listeners) {
    if ($listeners.Count -eq 0) {
        Fail "TCP $port is not listening"
    }

    foreach ($listener in $listeners) {
        if ($listener.LocalAddress -notin @('127.0.0.1', '::1')) {
            Fail "TCP $port is bound to non-loopback address $($listener.LocalAddress)"
        }

        $process = Get-CimInstance Win32_Process -Filter "ProcessId = $($listener.OwningProcess)" -ErrorAction SilentlyContinue
        if (-not (Test-AiProcess $process)) {
            Fail "TCP $port belongs to a process other than the dedicated Edge AI profile"
        }
    }

    try {
        $version = Invoke-RestMethod -Uri "http://127.0.0.1:$port/json/version" -TimeoutSec 2 -ErrorAction Stop
    } catch {
        Fail "dedicated Edge AI is listening on TCP $port but its CDP endpoint is unavailable"
    }

    $browser = [string]$version.Browser
    $webSocketDebuggerUrl = [string]$version.webSocketDebuggerUrl
    if ($browser -notlike 'Edg/*' -or $webSocketDebuggerUrl -notmatch "^ws://127\.0\.0\.1:$port/") {
        Fail "TCP $port did not identify as the dedicated loopback Edge CDP endpoint"
    }

    return $webSocketDebuggerUrl
}

if (-not (Test-Path -LiteralPath $edgePath -PathType Leaf)) {
    Fail "Edge executable not found: $edgePath"
}

$listeners = Get-CdpListeners
if ($listeners.Count -ne 0) {
    $webSocketDebuggerUrl = Confirm-AiEndpoint $listeners
    [Console]::Error.WriteLine("edge-ai: reusing dedicated Edge AI CDP on TCP $port")
    [Console]::Out.WriteLine($webSocketDebuggerUrl)
    exit 0
}

$existingAiProcesses = @(Get-CimInstance Win32_Process -Filter "Name = 'msedge.exe'" -ErrorAction SilentlyContinue | Where-Object { Test-AiProcess $_ })
if ($existingAiProcesses.Count -ne 0) {
    Fail "dedicated Edge AI is already running without CDP on TCP $port; close and reopen the dedicated Edge AI window"
}

$arguments = @(
    "--user-data-dir=`"$profilePath`"",
    "--remote-debugging-port=$port",
    '--remote-debugging-address=127.0.0.1',
    '--no-first-run',
    '--no-default-browser-check',
    'about:blank'
)

Start-Process -FilePath $edgePath -ArgumentList $arguments | Out-Null
[Console]::Error.WriteLine("edge-ai: started dedicated Edge AI profile on TCP $port")

$deadline = (Get-Date).AddSeconds(10)
do {
    Start-Sleep -Milliseconds 250
    $listeners = Get-CdpListeners
} while ($listeners.Count -eq 0 -and (Get-Date) -lt $deadline)

if ($listeners.Count -eq 0) {
    Fail "dedicated Edge AI did not expose CDP on TCP $port; close and reopen the dedicated Edge AI window"
}

$webSocketDebuggerUrl = Confirm-AiEndpoint $listeners
[Console]::Out.WriteLine($webSocketDebuggerUrl)
