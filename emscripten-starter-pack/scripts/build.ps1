Param()

$ErrorActionPreference = 'Stop'

# Ensure emcc is available (emsdk_env.ps1 should have been run)
$emcc = Get-Command emcc -ErrorAction SilentlyContinue
if (-not $emcc) {
  Write-Error "emcc not found. Run your emsdk_env.ps1 to set PATH, then retry."
  exit 1
}

# Make script location the working directory so it can be run from anywhere
$scriptDir = Split-Path -Parent $PSCommandPath
$packRoot = Split-Path -Parent $scriptDir

try {
  Push-Location $packRoot

  if (-not (Test-Path -Path 'dist')) {
    New-Item -ItemType Directory -Path 'dist' | Out-Null
  }

  Write-Host "[1/2] Building c/hello_stdio.c -> dist/hello.html"
  emcc c/hello_stdio.c -o dist/hello.html

  Write-Host "[2/2] Building c/hello_export.c -> dist/hello_export.wasm"
  emcc c/hello_export.c -O3 --no-entry -s STANDALONE_WASM=1 -s EXPORTED_FUNCTIONS=_add -o dist/hello_export.wasm

  Write-Host "Build complete. Serve the repo root and open emscripten-starter-pack/web/index.html"
}
finally {
  Pop-Location
}
