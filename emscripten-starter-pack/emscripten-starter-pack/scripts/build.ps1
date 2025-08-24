Param()

# Ensure emcc is available (emsdk_env.ps1 should have been run)
$emcc = Get-Command emcc -ErrorAction SilentlyContinue
if (-not $emcc) {
  Write-Error "emcc not found. Run: <path-to-emsdk>\emsdk_env.ps1"
  exit 1
}

Write-Host "[1/2] Building c/hello_stdio.c -> dist/hello.html"
emcc c/hello_stdio.c -o dist/hello.html

Write-Host "[2/2] Building c/hello_export.c -> dist/hello_export.wasm"
emcc c/hello_export.c -O3 --no-entry -s STANDALONE_WASM=1 -s EXPORTED_FUNCTIONS=_add -o dist/hello_export.wasm

Write-Host "Build complete. Serve the repo root and open web/index.html"
