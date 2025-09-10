#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning build artifacts..."

# Top-level demo artifacts
if [ -d "web/dist" ]; then
  echo "- Removing web/dist/"
  rm -rf web/dist
fi

# Starter pack artifacts
if [ -d "emscripten-starter-pack/dist" ]; then
  echo "- Removing emscripten-starter-pack/dist/"
  rm -rf emscripten-starter-pack/dist
fi

# Stray generated files accidentally placed in web/
for f in emscripten-starter-pack/web/hello_stdio.html emscripten-starter-pack/web/hello_stdio.js emscripten-starter-pack/web/hello_stdio.wasm; do
  if [ -f "$f" ]; then
    echo "- Removing stray $f"
    rm -f "$f"
  fi
done

echo "Done."

