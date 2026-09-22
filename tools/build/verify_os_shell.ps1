#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ExecutablePath,
    [Parameter(Mandatory)][string]$ReportDirectory
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'OS acceptance requires native Windows.' }
$process = [Diagnostics.Process]::new()
$started = $false
try {
    $process.StartInfo.FileName = $ExecutablePath
    $process.StartInfo.WorkingDirectory = Split-Path -Parent $ExecutablePath
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    foreach ($arg in @('--headless', '--', '--os-probe=verify')) { $process.StartInfo.ArgumentList.Add($arg) }
    $started = $process.Start()
    if (-not $started) { throw 'OS probe could not start.' }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $timedOut = -not $process.WaitForExit(30000)
    if ($timedOut) { $process.Kill($true); $process.WaitForExit() }
    $text = $stdoutTask.GetAwaiter().GetResult() + "`n" + $stderrTask.GetAwaiter().GetResult()
    $text | Set-Content -LiteralPath (Join-Path $ReportDirectory 'os-shell.log') -Encoding utf8
    if ($timedOut -or $process.ExitCode -ne 0) { throw 'OS navigation probe failed or timed out.' }
    if ($text -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|FATAL:|Parse Error:)') { throw 'OS probe reported a runtime error.' }
    if ($text -notmatch '(?m)^\[os-probe\] PASS selection navigation command isolation\r?$') { throw 'OS probe did not verify the expected native UI handoff.' }
    [ordered]@{
        test = 'windows-packaged-os-navigation-and-command-isolation'; status = 'passed'
        input_path = 'native Button signals through the OS presentation boundary'
        physical_mouse_playtest = 'not_run'; graphical_playtest = 'not_run'
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $ReportDirectory 'os-verification.json') -Encoding utf8
    Write-Host '[os-gate] PASS: city selection, app lifecycle and command isolation.'
}
finally {
    if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
    $process.Dispose()
}
& (Join-Path $PSScriptRoot 'verify_workspace.ps1') -ExecutablePath $ExecutablePath -ReportDirectory $ReportDirectory
& (Join-Path $PSScriptRoot 'verify_widgets.ps1') -ExecutablePath $ExecutablePath -ReportDirectory $ReportDirectory
