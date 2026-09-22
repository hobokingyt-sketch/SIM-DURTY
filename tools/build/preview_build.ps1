param(
	[string]$Godot = "godot",
	[string]$OutputDirectory = "build/windows"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "../..")).Path
$OutputPath = Join-Path $ProjectRoot $OutputDirectory
$ExePath = Join-Path $OutputPath "SIM-DURTY.exe"

Push-Location $ProjectRoot
try {
	$Commit = (& git rev-parse HEAD).Trim()
	if ($LASTEXITCODE -ne 0) {
		throw "Unable to read the current Git commit."
	}

	$Branch = (& git branch --show-current).Trim()
	if ([string]::IsNullOrWhiteSpace($Branch)) {
		$Branch = "detached"
	}

	$env:SIM_DURTY_BUILD_CHANNEL = "local-preview"
	$env:SIM_DURTY_BUILD_SHA = $Commit
	$env:SIM_DURTY_SOURCE_SHA = $Commit
	$env:SIM_DURTY_BUILD_REF = $Branch
	$env:SIM_DURTY_BUILD_NUMBER = "local"
	$env:SIM_DURTY_BUILD_RUN_ID = "local"
	$env:SIM_DURTY_BUILD_PR = "none"
	$env:SIM_DURTY_BUILD_TIME_UTC = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

	Write-Host "Generating SIM-DURTY build identity..."
	& $Godot --headless --path $ProjectRoot --script (Join-Path $ProjectRoot "tools/build/write_build_manifest.gd")
	if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

	Write-Host "Importing project..."
	& $Godot --headless --path $ProjectRoot --editor --quit-after 1
	if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

	Write-Host "Verifying build identity..."
	& $Godot --headless --path $ProjectRoot --script (Join-Path $ProjectRoot "tools/build/verify_build_manifest.gd")
	if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

	New-Item -ItemType Directory -Force -Path $OutputPath | Out-Null

	Write-Host "Exporting Windows preview..."
	& $Godot --headless --path $ProjectRoot --export-debug "Windows Preview" $ExePath
	if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

	Copy-Item `
		(Join-Path $ProjectRoot "game/core/build/generated/build_manifest.json") `
		(Join-Path $OutputPath "BUILD-METADATA.json") `
		-Force

	Write-Host "Preview created at $OutputPath"
}
finally {
	Pop-Location
}
