#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ExecutablePath,
    [Parameter(Mandatory)][string]$ReportDirectory
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Packaged persistence acceptance requires Windows.' }
New-Item -ItemType Directory -Force -Path $ReportDirectory | Out-Null
$observedSchemas = @{}
$savedHashes = @{}
$continuationHash = ''
foreach ($mode in @('write', 'read')) {
    $process = [Diagnostics.Process]::new()
    $started = $false
    try {
        $process.StartInfo.FileName = $ExecutablePath
        $process.StartInfo.WorkingDirectory = Split-Path -Parent $ExecutablePath
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        foreach ($arg in @('--headless', '--', "--skeleton-probe=$mode")) {
            $process.StartInfo.ArgumentList.Add($arg)
        }
        $started = $process.Start()
        if (-not $started) { throw "Could not start skeleton $mode process." }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $timedOut = -not $process.WaitForExit(30000)
        if ($timedOut) { $process.Kill($true); $process.WaitForExit() }
        $text = $stdoutTask.GetAwaiter().GetResult() + "`n" + $stderrTask.GetAwaiter().GetResult()
        $text | Set-Content -LiteralPath (Join-Path $ReportDirectory "skeleton-$mode.log") -Encoding utf8
        if ($timedOut) { throw "Skeleton $mode process timed out." }
        if ($process.ExitCode -ne 0) { throw "Skeleton $mode failed with exit code $($process.ExitCode)." }
        if ($text -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|FATAL:|Parse Error:)') {
            throw "Skeleton $mode reported an engine error."
        }
        if ($text -notmatch "(?m)^\[skeleton-probe\] PASS $mode cash_cents=2500 elapsed_minutes=45 completed_actions=3\r?$") {
            throw "Skeleton $mode did not prove the expected button/state/save/load result."
        }
        $schemas = @([regex]::Matches($text, '(?m)^save_schema: ([0-9]+)\r?$') |
            ForEach-Object { [int]$_.Groups[1].Value } | Select-Object -Unique)
        if ($schemas.Count -ne 1 -or $schemas[0] -ne 2) {
            throw "Skeleton $mode did not report the current schema-two contract."
        }
        $observedSchemas[$mode] = $schemas[0]
        $hashes = [regex]::Matches($text, '(?m)^state_hash: ([a-f0-9]{64})\r?$')
        if ($hashes.Count -lt 1) { throw "Skeleton $mode omitted its full state identity." }
        $savedHashes[$mode] = $hashes[$hashes.Count - 1].Groups[1].Value
        if ($mode -eq 'read') {
            $continuation = [regex]::Matches($text, '(?m)^\[spine-probe\] PASS continuation state_hash=([a-f0-9]{64})\r?$')
            if ($continuation.Count -ne 1) { throw 'The second process did not verify future RNG/work continuation.' }
            $continuationHash = $continuation[0].Groups[1].Value
        }
    }
    finally {
        if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        $process.Dispose()
    }
}
if ($observedSchemas['write'] -ne $observedSchemas['read'] -or $savedHashes['write'] -ne $savedHashes['read']) {
    throw 'Separate Windows processes did not restore the same complete checkpoint.'
}
[ordered]@{
    test = 'windows-packaged-two-process-save-load-and-continuation'
    status = 'passed'
    cash_cents = 2500
    elapsed_minutes = 45
    completed_actions = 3
    save_schema = $observedSchemas['read']
    saved_state_hash = $savedHashes['read']
    continuation_state_hash = $continuationHash
    continuation = 'next RNG draw and work command match the first-process oracle'
    input_path = 'native Button signals through application command handlers'
    physical_mouse_playtest = 'not_run'
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $ReportDirectory 'skeleton-verification.json') -Encoding utf8
Write-Host '[skeleton-gate] PASS: packaged Windows processes preserved schema, checkpoint and future continuation.'
& (Join-Path $PSScriptRoot 'verify_recovery_roundtrip.ps1') -ExecutablePath $ExecutablePath -ReportDirectory $ReportDirectory
& (Join-Path $PSScriptRoot 'verify_os_shell.ps1') -ExecutablePath $ExecutablePath -ReportDirectory $ReportDirectory
