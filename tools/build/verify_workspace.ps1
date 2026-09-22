#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ExecutablePath,
    [Parameter(Mandatory)][string]$ReportDirectory
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (-not $IsWindows) { throw 'Workspace acceptance requires Windows.' }
$proofs = @{}
foreach ($mode in @('write', 'read')) {
    $process = [Diagnostics.Process]::new()
    $started = $false
    try {
        $process.StartInfo.FileName = $ExecutablePath
        $process.StartInfo.WorkingDirectory = Split-Path -Parent $ExecutablePath
        $process.StartInfo.UseShellExecute = $false
        $process.StartInfo.RedirectStandardOutput = $true
        $process.StartInfo.RedirectStandardError = $true
        foreach ($arg in @('--headless', '--', "--workspace-probe=$mode")) {
            $process.StartInfo.ArgumentList.Add($arg)
        }
        $started = $process.Start()
        if (-not $started) { throw "Could not start workspace $mode." }
        $out = $process.StandardOutput.ReadToEndAsync()
        $err = $process.StandardError.ReadToEndAsync()
        $timeout = -not $process.WaitForExit(30000)
        if ($timeout) { $process.Kill($true); $process.WaitForExit() }
        $text = $out.GetAwaiter().GetResult() + "`n" + $err.GetAwaiter().GetResult()
        $text | Set-Content -LiteralPath (Join-Path $ReportDirectory "workspace-$mode.log") -Encoding utf8
        if ($timeout -or $process.ExitCode -ne 0) { throw "Workspace $mode failed or timed out." }
        if ($text -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|FATAL:|Parse Error:)') { throw 'Workspace runtime error.' }
        $proof = [regex]::Match($text, "(?m)^\[workspace-probe\] PASS $mode profile_hash=([a-f0-9]{64}) state_hash=([a-f0-9]{64})\r?$")
        if (-not $proof.Success) { throw "Missing workspace $mode proof." }
        $proofs[$mode] = @($proof.Groups[1].Value, $proof.Groups[2].Value)
    }
    finally {
        if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        $process.Dispose()
    }
}
if ($proofs['write'][0] -ne $proofs['read'][0] -or $proofs['write'][1] -ne $proofs['read'][1]) {
    throw 'New process did not restore the same layout and gameplay identities.'
}
[ordered]@{
    test = 'windows-packaged-independent-workspace-restore'; status = 'passed'
    profile_hash = $proofs['read'][0]; state_hash = $proofs['read'][1]
    input = 'viewport-dispatched mouse drag plus shared rail commands'
    gameplay_file_unchanged_by_layout = $true
    physical_mouse_playtest = 'not_run'; graphical_playtest = 'not_run'
} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $ReportDirectory 'workspace-verification.json') -Encoding utf8
Write-Host '[workspace-gate] PASS: independent layout restored without changing gameplay bytes.'
