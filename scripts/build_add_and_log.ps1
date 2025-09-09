Param()

# Build add_and_log.wasm at repo root using Emscripten (emcc)
# Prereq: Run <emsdk_path>\emsdk_env.ps1 first so emcc is on PATH

$ErrorActionPreference = 'Stop'

$emcc = Get-Command emcc -ErrorAction SilentlyContinue
if (-not $emcc) {
  Write-Error "emcc not found. Run your emsdk_env.ps1 to set PATH, then retry."
  exit 1
}

$root = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
Set-Location $root

Write-Host "[1/1] Building web/c/add_and_log.c -> web/add_and_log.wasm"

# Notes:
#  --no-entry            -> no start function (library-style)
#  -s STANDALONE_WASM=1  -> produce a .wasm that can run without JS glue
#  -Wl,--export=add_and_log -> export symbol as 'add_and_log' (no underscore)

emcc web/c/add_and_log.c `
  -O3 --no-entry -s STANDALONE_WASM=1 `
  -Wl,--export=add_and_log `
  -o web/add_and_log.wasm

Write-Host "Build complete. Serve repo root and open http://localhost:8000/web/index.html"
