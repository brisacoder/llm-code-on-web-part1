# Emscripten Student Starter Pack

This folder is a **drop-in** starter for your lecture/lab.

## What’s inside

- `INSTALL.md` — step-by-step Emscripten install (Ubuntu + Windows).
- `c/hello_stdio.c` — prints to stdout using `printf` (compiled to `hello.html` by Emscripten).
- `c/hello_export.c` — exports a function `add(int,int)` to be called from JS.
- `web/index.html` — minimal HTML + JS that loads a **standalone** WASM and calls the exported `_add`.
- `scripts/build.sh` — Bash build script (Linux/macOS).
- `scripts/build.ps1` — PowerShell build script (Windows).
- `dist/` — output directory for build artifacts.

## Quick Start (after installing emsdk)

**Linux/macOS**

```bash
source ~/emsdk/emsdk_env.sh    # or path where you cloned emsdk
bash scripts/build.sh
python3 -m http.server 8080
# open http://localhost:8080/web/index.html
```

**Windows (PowerShell)**

```powershell
.\..\emsdk\emsdk_env.ps1  # adjust path to your emsdk clone, or run from within it
powershell -ExecutionPolicy Bypass -File scripts\build.ps1
python -m http.server 8080
# open http://localhost:8080/web/index.html
```

> If you see `WebAssembly.instantiate: Import #0 module="env" function="_add" error`,
double-check you compiled `hello_export.c` with the **exact flags** used in the scripts.

## What you should see

- `dist/hello.html` (Emscripten-generated) prints **“Hello, WebAssembly!”** in the browser console.
- `web/index.html` shows **Result: 12** after calling `_add(7,5)` from the standalone WASM.
