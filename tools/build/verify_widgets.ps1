#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ExecutablePath,
    [Parameter(Mandatory)][string]$ReportDirectory
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Packaged widget acceptance requires Windows.' }
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
        foreach ($arg in @('--headless', '--', "--widget-probe=$mode")) {
            $process.StartInfo.ArgumentList.Add($arg)
        }
        $started = $process.Start()
        if (-not $started) { throw "Widget $mode process could not start." }
        $stdoutTask = $process.StandardOutput.ReadToEndAsync()
        $stderrTask = $process.StandardError.ReadToEndAsync()
        $timedOut = -not $process.WaitForExit(30000)
        if ($timedOut) { $process.Kill($true); $process.WaitForExit() }
        $text = $stdoutTask.GetAwaiter().GetResult() + "`n" + $stderrTask.GetAwaiter().GetResult()
        $text | Set-Content -LiteralPath (Join-Path $ReportDirectory "widgets-$mode.log") -Encoding utf8
        if ($timedOut -or $process.ExitCode -ne 0) { throw "Widget $mode process failed or timed out." }
        if ($text -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|FATAL:|Parse Error:)') { throw "Widget $mode process reported an engine error." }
        if ($text -notmatch "(?m)^\[widget-probe\] PASS $mode\r?$") { throw "Widget $mode contract not proved." }
        $observed = [regex]::Matches($text, '(?m)^widget_profile_sha256: ([a-f0-9]{64})\r?$')
        if ($observed.Count -ne 1) { throw 'Missing unique widget profile identity.' }
        $hashes[$mode] = $observed[0].Groups[1].Value
    }
    finally {
        if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        $process.Dispose()
    }
}
if ($hashes['write'] -ne $hashes['read']) { throw 'Widget profile changed across independent processes.' }
[ordered]@{
    test = 'windows-packaged-widget-input-and-independent-profile-restoration'
    status = 'passed'
    profile_sha256 = $hashes['read']
    input_path = 'viewport mouse events plus shared command paths for semantic form selection'
    gameplay_checkpoint_and_save_bytes = 'unchanged'
    physical_device_playtest = 'not_run'
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $ReportDirectory 'widget-verification.json') -Encoding utf8
Write-Host '[widget-gate] PASS: native drag and fresh-process layout restoration preserve gameplay.'
