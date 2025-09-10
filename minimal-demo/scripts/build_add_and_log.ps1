Param()

# Build add_and_log.wasm for the minimal demo using Emscripten (emcc)
# Prereq: Run <emsdk_path>\emsdk_env.ps1 first so emcc is on PATH

$ErrorActionPreference = 'Stop'

$emcc = Get-Command emcc -ErrorAction SilentlyContinue
if (-not $emcc) {
  Write-Error "emcc not found. Run your emsdk_env.ps1 to set PATH, then retry."
  exit 1
}

$scriptDir = Split-Path -Parent $PSCommandPath
$demoRoot  = Split-Path -Parent $scriptDir

Write-Host "[1/1] Building c/add_and_log.c -> dist/add_and_log.wasm"

# Notes:
#  --no-entry            -> no start function (library-style)
#  -s STANDALONE_WASM=1  -> produce a .wasm that can run without JS glue
#  -Wl,--export=add_and_log -> export symbol as 'add_and_log' (no underscore)


if (-not (Test-Path -Path (Join-Path $demoRoot 'dist'))) { New-Item -ItemType Directory -Path (Join-Path $demoRoot 'dist') | Out-Null }

try {
  Push-Location $demoRoot
  emcc c/add_and_log.c `
    -O3 --no-entry -s STANDALONE_WASM=1 `
    "-Wl,--allow-undefined" `
    "-Wl,--export=add_and_log" `
    -o dist/add_and_log.wasm
}
finally {
  Pop-Location
}

Write-Host "Build complete. Serve repo root and open http://localhost:8000/minimal-demo/index.html"
