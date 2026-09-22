param(
	[string]$Godot = "godot"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

Write-Host "SIM-DURTY project import..."
& $Godot --headless --path $ProjectRoot --editor --quit-after 1
if ($LASTEXITCODE -ne 0) {
	exit $LASTEXITCODE
}

Write-Host "SIM-DURTY architecture guard..."
& $Godot --headless --path $ProjectRoot --script (Join-Path $ProjectRoot "tools/validation/architecture_guard.gd")
if ($LASTEXITCODE -ne 0) {
	exit $LASTEXITCODE
}

Write-Host "SIM-DURTY automated tests..."
& $Godot --headless --path $ProjectRoot --script (Join-Path $ProjectRoot "tests/runner.gd")
if ($LASTEXITCODE -ne 0) {
	exit $LASTEXITCODE
}

Write-Host "SIM-DURTY main-scene boot..."
& $Godot --headless --path $ProjectRoot --quit-after 2
exit $LASTEXITCODE
