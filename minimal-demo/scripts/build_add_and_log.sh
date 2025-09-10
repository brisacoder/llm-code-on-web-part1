#!/usr/bin/env bash
set -euo pipefail

# Build add_and_log.wasm for the minimal demo using Emscripten (emcc)
# Prereq: source <emsdk_path>/emsdk_env.sh so emcc is on PATH

if ! command -v emcc >/dev/null 2>&1; then
  echo "error: emcc not found. Run: source <emsdk>/emsdk_env.sh" >&2
  exit 1
fi

demo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$demo_root"

echo "[1/1] Building c/add_and_log.c -> dist/add_and_log.wasm"

# --no-entry: no start function
# STANDALONE_WASM=1: loadable with WebAssembly.instantiate
# export symbol 'add_and_log' (no underscore)
mkdir -p dist

emcc c/add_and_log.c \
  -O3 --no-entry -s STANDALONE_WASM=1 \
  -Wl,--export=add_and_log \
  -o dist/add_and_log.wasm

echo "Build complete. Serve repo root and open http://localhost:8000/minimal-demo/index.html"
