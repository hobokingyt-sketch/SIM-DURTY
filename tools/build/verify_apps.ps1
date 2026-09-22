#Requires -Version 7.0
[CmdletBinding()]
param([Parameter(Mandatory)][string]$ExecutablePath,[Parameter(Mandatory)][string]$ReportDirectory)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Packaged app acceptance requires Windows.' }
$p = [Diagnostics.Process]::new(); $started = $false
try {
    $p.StartInfo.FileName = $ExecutablePath; $p.StartInfo.WorkingDirectory = Split-Path -Parent $ExecutablePath
    $p.StartInfo.UseShellExecute = $false; $p.StartInfo.RedirectStandardOutput = $true; $p.StartInfo.RedirectStandardError = $true
    foreach ($arg in @('--headless','--','--app-probe=verify')) { $p.StartInfo.ArgumentList.Add($arg) }
    $started = $p.Start(); if (-not $started) { throw 'App probe could not start.' }
    $out=$p.StandardOutput.ReadToEndAsync(); $err=$p.StandardError.ReadToEndAsync(); $timedOut=-not $p.WaitForExit(30000)
    if ($timedOut) { $p.Kill($true); $p.WaitForExit() }
    $text=$out.GetAwaiter().GetResult()+[Environment]::NewLine+$err.GetAwaiter().GetResult()
    $text | Set-Content -LiteralPath (Join-Path $ReportDirectory 'apps.log') -Encoding utf8
    if ($timedOut -or $p.ExitCode -ne 0) { throw 'App probe failed or timed out.' }
    if ($text -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|FATAL:|Parse Error:)') { throw 'App probe reported runtime error.' }
    if ($text -notmatch '(?m)^\[app-probe\] PASS lifecycle navigation continuity\r?$') { throw 'App lifecycle contract not proved.' }
    [ordered]@{test='windows-packaged-app-lifecycle-navigation';status='passed';center_focus='operations';rail_host='session-record';gameplay_checkpoint='unchanged'} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $ReportDirectory 'app-verification.json') -Encoding utf8
    Write-Host '[app-gate] PASS: app lifecycle preserves city and gameplay state.'
} finally { if ($started -and -not $p.HasExited) { $p.Kill($true); $p.WaitForExit() }; $p.Dispose() }
