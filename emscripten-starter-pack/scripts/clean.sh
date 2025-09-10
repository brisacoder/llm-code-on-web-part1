#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd)"
pack_root="$(cd "$script_dir/.." && pwd)"

echo "Cleaning Emscripten starter-pack artifacts..."

if [ -d "$pack_root/dist" ]; then
  echo "- Removing $pack_root/dist"
  rm -rf "$pack_root/dist"
fi

# Stray generated files accidentally placed under web/
for f in hello_stdio.html hello_stdio.js hello_stdio.wasm hello_export.wasm; do
  p="$pack_root/web/$f"
  if [ -f "$p" ]; then
    echo "- Removing stray $p"
    rm -f "$p"
  fi
done

echo "Done."

