#Requires -Version 7.0
[CmdletBinding()]
param(
    [string]$ArchivePath,
    [string]$ExpectedSha,
    [string]$ExpectedArchiveHash,
    [string]$ExpectedGodotVersion,
    [string]$ReportDirectory,
    [switch]$SelfTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-RuntimeEngineVersion {
    param([string]$Actual, [string]$Expected)
    # Engine.get_version_info().string is not the CLI --version representation.
    if ($Actual -cne "$Expected-stable (official)") {
        throw "Expected official Godot $Expected runtime, got '$Actual'."
    }
}

function Assert-PreviewLog {
    param([string]$Text, [System.Collections.IDictionary]$Metadata)
    if ($Text -match '(?im)^\s*(SCRIPT ERROR:|ERROR:|FATAL:|Parse Error:|Failed loading resource:)') {
        throw 'Runtime error found in the packaged game log.'
    }
    $build = [regex]::Escape([string]$Metadata['build_id'])
    if ($Text -notmatch "(?m)^\[SIM-DURTY\].*boot OK \| build=$build\r?$") {
        throw 'Configured main scene did not emit its boot marker.'
    }
    $fields = @{
        build_id = 'build_id'; commit_sha = 'commit_sha'; source_sha = 'source_sha'
        game_version = 'game_version'; godot_version = 'engine_version'
    }
    foreach ($field in $fields.Keys) {
        $value = [regex]::Escape([string]$Metadata[$fields[$field]])
        if ($Text -notmatch "(?m)^${field}: $value\r?$") {
            throw "Packaged runtime identity mismatch: $field"
        }
    }
    if ($Text -notmatch '(?m)^platform: Windows\r?$') {
        throw 'Packaged runtime did not report Windows.'
    }
}

if ($SelfTest) {
    $sample = @{
        build_id = 'preview-1.1-abc'; commit_sha = 'abc'; source_sha = 'abc'
        game_version = 'test'; engine_version = 'test-engine'
    }
    $valid = "[SIM-DURTY] Test boot OK | build=preview-1.1-abc`nbuild_id: preview-1.1-abc`ncommit_sha: abc`nsource_sha: abc`ngame_version: test`ngodot_version: test-engine`nplatform: Windows"
    Assert-PreviewLog -Text $valid -Metadata $sample
    $badCases = @(
        ($valid + "`nSCRIPT ERROR: injected test failure"),
        ($valid.Replace('commit_sha: abc', 'commit_sha: wrong')),
        ($valid.Replace('boot OK', 'did not boot')),
        ($valid.Replace('platform: Windows', 'platform: Linux'))
    )
    foreach ($bad in $badCases) {
        $rejected = $false
        try { Assert-PreviewLog -Text $bad -Metadata $sample }
        catch { $rejected = $true }
        if (-not $rejected) { throw 'Smoke validator accepted an invalid fixture.' }
    }
    Assert-RuntimeEngineVersion -Actual '4.7.2-stable (official)' -Expected '4.7.2'
    foreach ($badVersion in @('4.7.3-stable (official)', '4.7.2-beta1 (official)', '4.7.2.stable.official.hash')) {
        $rejected = $false
        try { Assert-RuntimeEngineVersion -Actual $badVersion -Expected '4.7.2' }
        catch { $rejected = $true }
        if (-not $rejected) { throw 'Engine validator accepted an invalid runtime-version fixture.' }
    }
    Write-Host '[preview-gate] PASS: valid log/version fixtures accepted; 7 invalid fixtures rejected.'
    return
}

if (-not $IsWindows) { throw 'The exported Windows game must be tested on Windows.' }
if ($ExpectedSha -notmatch '^[a-f0-9]{40}$') { throw 'ExpectedSha must be a full Git SHA.' }
if ($ExpectedArchiveHash -notmatch '^[a-fA-F0-9]{64}$') { throw 'ExpectedArchiveHash must be SHA-256.' }
if ($ExpectedGodotVersion -notmatch '^\d+\.\d+\.\d+$') { throw 'An exact Godot version is required.' }
if ([string]::IsNullOrWhiteSpace($ReportDirectory)) { throw 'ReportDirectory is required.' }
$archive = (Resolve-Path -LiteralPath $ArchivePath).Path
$actualHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
if ($actualHash -ne $ExpectedArchiveHash.ToLowerInvariant()) { throw 'Archive checksum mismatch.' }
New-Item -ItemType Directory -Path $ReportDirectory -Force | Out-Null
$reports = (Resolve-Path -LiteralPath $ReportDirectory).Path
$scratch = Join-Path ([IO.Path]::GetTempPath()) ('SIM DURTY portable test ' + [guid]::NewGuid())
New-Item -ItemType Directory -Path $scratch | Out-Null
$process = $null
$started = $false
try {
    Expand-Archive -LiteralPath $archive -DestinationPath $scratch
    foreach ($name in @('SIM-DURTY.exe', 'SIM-DURTY.pck', 'BUILD-METADATA.json')) {
        $path = Join-Path $scratch $name
        if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Package is missing $name" }
        if ((Get-Item -LiteralPath $path).Length -eq 0) { throw "Package contains empty $name" }
    }
    if (Test-Path -LiteralPath (Join-Path $scratch 'project.godot')) {
        throw 'Expected an exported game, not a source-project checkout.'
    }
    $metadata = Get-Content -LiteralPath (Join-Path $scratch 'BUILD-METADATA.json') -Raw | ConvertFrom-Json -AsHashtable
    if ($metadata['manifest_schema'] -ne 1) { throw 'Unsupported build manifest schema.' }
    foreach ($field in @('build_id', 'commit_sha', 'source_sha', 'game_version', 'engine_version')) {
        if (-not ($metadata[$field] -is [string]) -or [string]::IsNullOrWhiteSpace($metadata[$field])) {
            throw "Missing or invalid build metadata: $field"
        }
    }
    if ($metadata['commit_sha'] -ne $ExpectedSha -or $metadata['source_sha'] -ne $ExpectedSha) {
        throw 'The archive does not identify the expected source commit.'
    }
    Assert-RuntimeEngineVersion -Actual $metadata['engine_version'] -Expected $ExpectedGodotVersion
    if ($metadata['channel'] -ne 'preview') { throw 'Expected a generated preview, not local fallback.' }

    # Start the exported EXE outside the checkout, with no editor or source-project argument.
    $process = [Diagnostics.Process]::new()
    $process.StartInfo.FileName = Join-Path $scratch 'SIM-DURTY.exe'
    $process.StartInfo.WorkingDirectory = $scratch
    $process.StartInfo.UseShellExecute = $false
    $process.StartInfo.RedirectStandardOutput = $true
    $process.StartInfo.RedirectStandardError = $true
    foreach ($arg in @('--headless', '--quit-after', '90', '--log-file', (Join-Path $reports 'engine.log'))) {
        $process.StartInfo.ArgumentList.Add($arg)
    }
    $started = $process.Start()
    if (-not $started) { throw 'Unable to launch the packaged executable.' }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    $timedOut = -not $process.WaitForExit(30000)
    if ($timedOut) {
        $process.Kill($true)
        $process.WaitForExit()
    }
    $stdout = $stdoutTask.GetAwaiter().GetResult()
    $stderr = $stderrTask.GetAwaiter().GetResult()
    $stdout | Set-Content -LiteralPath (Join-Path $reports 'stdout.log') -Encoding utf8
    $stderr | Set-Content -LiteralPath (Join-Path $reports 'stderr.log') -Encoding utf8
    if ($timedOut) { throw 'Packaged executable exceeded its 30-second smoke-test timeout.' }
    if ($process.ExitCode -ne 0) { throw "Packaged executable exited with code $($process.ExitCode)." }
    $engineLog = Join-Path $reports 'engine.log'
    if (-not (Test-Path -LiteralPath $engineLog)) { throw 'Engine did not write its startup log.' }
    $allLogs = $stdout + "`n" + $stderr + "`n" + (Get-Content -LiteralPath $engineLog -Raw)
    Assert-PreviewLog -Text $allLogs -Metadata $metadata

    [ordered]@{
        test = 'windows-packaged-headless-boot'; status = 'passed'; exit_code = $process.ExitCode
        commit_sha = $ExpectedSha; build_id = $metadata['build_id']; archive_sha256 = $actualHash
        engine_version = $metadata['engine_version']; platform = 'Windows'
        graphical_playtest = 'not_run'; clipboard_test = 'not_run'
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $reports 'verification.json') -Encoding utf8
    Write-Host "[preview-gate] PASS: $($metadata['build_id']) launched from the delivered ZIP on Windows."
}
catch {
    $_.Exception.Message | Set-Content -LiteralPath (Join-Path $reports 'failure.txt') -Encoding utf8
    throw
}
finally {
    if ($null -ne $process) {
        if ($started -and -not $process.HasExited) { $process.Kill($true); $process.WaitForExit() }
        $process.Dispose()
    }
    Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue
}
