# WebAssembly– Roadmap

This repo takes you from “What is WebAssembly?” to two small, working browser demos. Use `install.md` for setup and running.

## 0) Install & Run
- install.md: SDK setup, local server, and quickstart for both demos
- web/index.html: minimal JS ↔ Wasm round-trip (build via `scripts/build_add_and_log.*`)

## 1) Foundations
- intro_to_wasm.md: how Wasm runs; imports/exports; browser vs Node/WASI

## 2) Architecture
- intro_to_wasm.md#os-illusion-stack-view: OS Illusion stack (browser vs WASI)
- intro_to_wasm.md#syscall-round-trip-sequence: Syscall Round Trip
- round_trip_flow.md: JS ↔ Wasm ↔ JS back-call and return values

## 3) Demos
- Top-level demo: build `web/add_and_log.wasm` with `scripts/build_add_and_log.ps1` (or `.sh`), then open `web/index.html` via a local server
- Emscripten pack demo: run `emscripten-starter-pack/scripts/build.*` and open `emscripten-starter-pack/web/index.html`

## Layout
```
./
├─ web/
│  ├─ index.html                 # top-level demo (loads add_and_log.wasm)
│  └─ c/add_and_log.c            # source for the demo
├─ scripts/
│  ├─ build_add_and_log.ps1
│  └─ build_add_and_log.sh
├─ emscripten-starter-pack/
│  ├─ c/                         # Emscripten samples
│  ├─ scripts/                   # build.sh / build.ps1
│  └─ web/index.html             # loads dist/hello_export.wasm
├─ install.md
├─ intro_to_wasm.md
├─ round_trip_flow.md
├─ README.md
└─ LICENSE / .gitignore
```
