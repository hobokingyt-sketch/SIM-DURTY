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
    }
    finally {
        if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        $process.Dispose()
    }
}
[ordered]@{
    test = 'windows-packaged-two-process-save-load'
    status = 'passed'
    cash_cents = 2500
    elapsed_minutes = 45
    completed_actions = 3
    save_schema = 1
    input_path = 'native Button signals through application command handlers'
    physical_mouse_playtest = 'not_run'
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $ReportDirectory 'skeleton-verification.json') -Encoding utf8
Write-Host '[skeleton-gate] PASS: packaged Windows processes saved and reloaded the same state.'
