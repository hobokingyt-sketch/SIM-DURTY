#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ExecutablePath,
    [Parameter(Mandatory)][string]$ReportDirectory
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Recovery acceptance requires the native Windows package.' }
New-Item -ItemType Directory -Force -Path $ReportDirectory | Out-Null
$hashes = @{}
foreach ($mode in @('write', 'read')) {
    $process = [Diagnostics.Process]::new()
    $started = $false
    try {
        $process.StartInfo.FileName = $ExecutablePath
        $process.StartInfo.WorkingDirectory = Split-Path -Parent $ExecutablePath
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        foreach ($arg in @('--headless', '--', "--recovery-probe=$mode")) {
            $process.StartInfo.ArgumentList.Add($arg)
        }
        $started = $process.Start()
        if (-not $started) { throw "Could not start recovery $mode process." }
        $stdout = $process.StandardOutput.ReadToEndAsync()
        $stderr = $process.StandardError.ReadToEndAsync()
        $timedOut = -not $process.WaitForExit(30000)
        if ($timedOut) { $process.Kill($true); $process.WaitForExit() }
        $text = $stdout.GetAwaiter().GetResult() + "`n" + $stderr.GetAwaiter().GetResult()
        $text | Set-Content -LiteralPath (Join-Path $ReportDirectory "recovery-$mode.log") -Encoding utf8
        if ($timedOut -or $process.ExitCode -ne 0) { throw "Recovery $mode failed or timed out." }
        if ($text -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|FATAL:|Parse Error:)') {
            throw "Recovery $mode reported an engine error."
        }
        $matches = [regex]::Matches($text, "(?m)^\[recovery-probe\] PASS $mode state_hash=([a-f0-9]{64})\r?$")
        if ($matches.Count -ne 1) { throw "Recovery $mode did not prove its contract." }
        $hashes[$mode] = $matches[0].Groups[1].Value
    }
    finally {
        if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        $process.Dispose()
    }
}
if ($hashes['write'] -ne $hashes['read']) { throw 'Recovered state differs between Windows processes.' }
[ordered]@{
    test = 'windows-packaged-backup-recovery-and-restart'
    status = 'passed'
    recovered_state_hash = $hashes['read']
    original_and_backup = 'byte-identical retention verified by first process'
    continuation = 'auto-load and next RNG/work verified by second process'
    scope = 'isolated CI slot only; native button signals, not physical input'
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $ReportDirectory 'recovery-verification.json') -Encoding utf8
Write-Host '[recovery-gate] PASS: recovery, original preservation, restart and continuation.'
