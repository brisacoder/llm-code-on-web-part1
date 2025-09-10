#!/usr/bin/env bash
set -euo pipefail

echo "Cleaning build artifacts..."

# Resolve paths relative to this script
script_dir="$(cd "$(dirname "$0")" && pwd)"
demo_root="$(cd "$script_dir/.." && pwd)"
repo_root="$(cd "$demo_root/.." && pwd)"

# Minimal demo artifacts
if [ -d "$demo_root/dist" ]; then
  echo "- Removing $demo_root/dist"
  rm -rf "$demo_root/dist"
fi

# Starter pack artifacts
if [ -d "$repo_root/emscripten-starter-pack/dist" ]; then
  echo "- Removing $repo_root/emscripten-starter-pack/dist"
  rm -rf "$repo_root/emscripten-starter-pack/dist"
fi

# Stray generated files accidentally placed in starter-pack/web/
for f in hello_stdio.html hello_stdio.js hello_stdio.wasm; do
  p="$repo_root/emscripten-starter-pack/web/$f"
  if [ -f "$p" ]; then
    echo "- Removing stray $p"
    rm -f "$p"
  fi
done

echo "Done."
