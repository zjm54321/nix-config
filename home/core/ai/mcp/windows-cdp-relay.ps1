$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

$client = $null
try {
    $client = [System.Net.Sockets.TcpClient]::new()
    $connectTask = $client.ConnectAsync('127.0.0.1', 9223)
    if (-not $connectTask.Wait(5000)) {
        throw 'Connection to the dedicated Edge AI CDP endpoint timed out.'
    }
    $null = $connectTask.GetAwaiter().GetResult()

    $networkStream = $client.GetStream()
    $standardInput = [Console]::OpenStandardInput()
    $standardOutput = [Console]::OpenStandardOutput()
    $inputToSocket = $standardInput.CopyToAsync($networkStream)
    $socketToOutput = $networkStream.CopyToAsync($standardOutput)
    $completedIndex = [Threading.Tasks.Task]::WaitAny([Threading.Tasks.Task[]]@($inputToSocket, $socketToOutput))

    if ($completedIndex -eq 0) {
        $null = $inputToSocket.GetAwaiter().GetResult()
        try { $client.Client.Shutdown([System.Net.Sockets.SocketShutdown]::Send) } catch { }
        if (-not $socketToOutput.Wait(5000)) { throw 'CDP peer did not finish draining within five seconds.' }
        $null = $socketToOutput.GetAwaiter().GetResult()
    } else {
        $null = $socketToOutput.GetAwaiter().GetResult()
    }
} catch {
    [Console]::Error.WriteLine("windows-cdp-relay: $($_.Exception.Message)")
    exit 1
} finally {
    if ($null -ne $client) { $client.Dispose() }
}
