# Emscripten Starter Pack — Roadmap

This repository is a hands-on path from “What is WebAssembly?” to a tiny JS ⇄ Wasm demo you can run locally (browser or Node/WASI). The top-level README is a **roadmap**; each section links to focused docs.

## 0) Install & Run
- 📦 [INSTALL.md](./INSTALL.md) — prerequisites, local dev server, quick sanity checks.
- ▶️ `index.html` — minimal page that instantiates a prebuilt `.wasm` and does a JS ⇄ Wasm round-trip.

## 1) Foundations (start here)
- 🧭 [intro_to_wasm.md](./intro_to_wasm.md) — **lecture intro**: what Wasm is, how it runs, browser vs Node/WASI, memory model, imports/exports, and when to choose Emscripten vs WASI.

## 2) Architecture & Mental Models
- 🧩 [illusion.md](./illusion.md) — “illusion stack”: CPython/C → libc → (Emscripten or WASI) → Wasm → engine → host.
- 🔁 [round_trip_flow.md](./round_trip_flow.md) — JS → Wasm → JS back-call (imports) and return values.
- 🧵 [syscall_roundtrip.md](./syscall_roundtrip.md) — one syscall’s journey (Python `open`) across the boundary.

## 3) Demos & Labs
- 🌐 **Browser demo**: open `index.html` with a local server (see INSTALL).
- 🟢 **Node + WASI demo**: coming next (WASI entrypoint + preopens).

## 4) Tooling Choices (cheat sheet)
- **Compile to Wasm**
  - Emscripten (C/C++/CPython + browser shims)
  - Rust (`wasm32-unknown-unknown`, `wasm32-wasi`)
  - Zig / Clang + WASI sysroot
- **Runtimes**
  - Browser engines (V8/SpiderMonkey/JavaScriptCore)
  - Node’s `node:wasi`, Wasmtime, Wasmer, WasmEdge

## 5) Roadmap
- [ ] Add Node + WASI sample (`wasi_main.wasm` + `node:wasi` runner)
- [ ] Show SIMD and Threads notes (COOP/COEP for browsers)
- [ ] Add “passing TypedArrays / shared memory” example
- [ ] Benchmark harness (JS vs Wasm kernel)

## Repository Layout

```bash
./
├─ emscripten-starter-pack/ # (placeholder for future samples)
├─ index.html # tiny browser demo
├─ INSTALL.md # setup and run instructions
├─ intro_to_wasm.md # lecture intro (start here)
├─ illusion.md # layers/illusion diagram (Mermaid)
├─ round_trip_flow.md # JS ⇄ Wasm round-trip (Mermaid)
├─ syscall_roundtrip.md # syscall sequence (Mermaid)
├─ README.md # this roadmap
└─ LICENSE / .gitignore
```