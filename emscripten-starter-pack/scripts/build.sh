#!/usr/bin/env bash
set -euo pipefail

# Ensure emsdk env is loaded (emcc in PATH)
if ! command -v emcc >/dev/null 2>&1; then
  echo "error: emcc not found. Run: source ~/emsdk/emsdk_env.sh"
  exit 1
fi

# Build printf example (generates .html + .js + .wasm into dist/)
echo "[1/2] Building hello_stdio.c -> dist/hello.html"
emcc c/hello_stdio.c -o dist/hello.html

# Build standalone wasm with exported function `_add`
# Notes:
#  --no-entry: no main(); just exports
#  -s STANDALONE_WASM=1: produce a wasm that can be loaded by WebAssembly.instantiate directly
#  -s EXPORTED_FUNCTIONS=_add: export the symbol name `_add` (C name `add`)
echo "[2/2] Building hello_export.c -> dist/hello_export.wasm"
emcc c/hello_export.c -O3 --no-entry -s STANDALONE_WASM=1 -s EXPORTED_FUNCTIONS=_add -o dist/hello_export.wasm

echo "Build complete. Serve the repo root and open web/index.html"
