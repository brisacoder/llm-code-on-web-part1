Param()

$ErrorActionPreference = 'Stop'

Write-Host "Cleaning build artifacts..."

# Resolve important paths relative to this script
$scriptDir = Split-Path -Parent $PSCommandPath
$demoRoot  = Split-Path -Parent $scriptDir           # minimal-demo/
$repoRoot  = Split-Path -Parent $demoRoot            # repo root

# Minimal demo artifacts
$demoDist = Join-Path $demoRoot 'dist'
if (Test-Path $demoDist) {
  Write-Host "- Removing $demoDist"
  Remove-Item -Recurse -Force $demoDist
}

# Starter pack artifacts
$packDist = Join-Path (Join-Path $repoRoot 'emscripten-starter-pack') 'dist'
if (Test-Path $packDist) {
  Write-Host "- Removing $packDist"
  Remove-Item -Recurse -Force $packDist
}

# Stray generated files accidentally placed in starter-pack/web/
$packWeb = Join-Path (Join-Path $repoRoot 'emscripten-starter-pack') 'web'
$strays = @('hello_stdio.html','hello_stdio.js','hello_stdio.wasm') | ForEach-Object { Join-Path $packWeb $_ }
foreach($f in $strays){ if(Test-Path $f){ Write-Host "- Removing stray $f"; Remove-Item -Force $f } }

Write-Host "Done."
