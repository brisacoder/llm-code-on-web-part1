# Running LLM Code on the Web: Wasm/Pyodide, Part I

This repo is Part I of a 3‑part series on running LLM‑generated code on the web. Here we focus on Wasm fundamentals and two minimal browser demos. Use the Install & Run section below for setup and running.

Series roadmap
- Part I (this repo): Wasm basics + minimal JS <-> Wasm demos
- Part II: Pyodide in the browser + Node/Express integration for running Python (LLM‑generated) safely and interactively
- Part III: Hardening and shipping — packaging strategies, caching, performance tips, and end‑to‑end workflows

## 0) Install & Run
- See [Install & Run](#install--run-lecture-quickstart) for SDK setup, local server, and quickstart
- `web/index.html`: minimal JS <-> Wasm round-trip (build via `scripts/build_add_and_log.*`)

## 1) Foundations
- [Intro to Wasm](intro_to_wasm.md): how Wasm runs; imports/exports; browser vs Node/WASI
- [Install & Run](#install--run-lecture-quickstart): quickstart and SDK setup

## 2) Architecture
- [OS Illusion stack (browser vs WASI)](intro_to_wasm.md#os-illusion-stack-view)
- [JS -> Wasm -> JS back-call and return values](intro_to_wasm.md#js-wasm-round-trip-browser)
- [Syscall Round Trip](intro_to_wasm.md#syscall-round-trip-sequence)
## 3) Demos
- Top-level demo: build `web/dist/add_and_log.wasm` with `scripts/build_add_and_log.ps1` (or `.sh`), then open `web/index.html` via a local server
- Emscripten pack demo: run `emscripten-starter-pack/scripts/build.*` and open `emscripten-starter-pack/web/index.html`

Why two demos?
- `web/dist/add_and_log.wasm`: a minimal, hand-wired JS <-> Wasm round-trip. Tiny C (`web/c/add_and_log.c`), no Emscripten runtime or glue; you manually instantiate and call the export.
- `emscripten-starter-pack`: the typical Emscripten toolchain flow. Can generate HTML/JS glue, demonstrates stdio/filesystem support, and a fuller project layout with multiple examples.
About exports
- Top-level demo: the function is exported via the linker flag `-Wl,--export=add_and_log` (see `scripts/build_add_and_log.*`). There is no separate “export-only” C file; the export comes directly from `add_and_log.c`.
- Starter pack: the `c/hello_export.c` example exists to explicitly show exporting a pure function using `-s EXPORTED_FUNCTIONS=_add` and loading it from `web/index.html`.

## Layout
```
./
├─ web/
�  �� index.html                 # top-level demo (loads dist/add_and_log.wasm)
│  └─ c/add_and_log.c            # source for the demo
├─ scripts/
│  ├─ build_add_and_log.ps1
�  �� build_add_and_log.ps1
�  �� build_add_and_log.sh
�  �� clean.ps1 / clean.sh       # remove build artifacts (web/dist, pack/dist)
│  ├─ c/                         # Emscripten samples
│  ├─ scripts/                   # build.sh / build.ps1
│  └─ web/index.html             # loads dist/hello_export.wasm
├─ intro_to_wasm.md
├─ README.md
└─ LICENSE / .gitignore
```

---

# Install & Run (Lecture Quickstart)

This guide has two parts:
- Quickstart to build and run the demos (with a local server).
- Emscripten SDK (concise) pointers and gotchas (see below).

---

## Quickstart: Run the Browser Demos

Prerequisites:
- Emscripten SDK installed and environment loaded so `emcc` is on PATH (see below if needed).
- A local static file server (browsers block `fetch` from `file://`).

Start a server from the repo root (pick one):
- Python: `python -m http.server 8000` (or `py -m http.server 8000` on Windows)
- Node: `npx serve .`
- VS Code: Live Server extension

1) Top-level JS <-> Wasm demo
- Build the Wasm once:
  - PowerShell: `scripts/build_add_and_log.ps1`
  - Bash: `scripts/build_add_and_log.sh`
- Open: `http://localhost:8000/web/index.html`
- Click “Run”. You should see console log “WASM says: 12” and “Result: 12”.

2) Emscripten Starter Pack demo
- Build:
  - PowerShell: `emscripten-starter-pack/scripts/build.ps1`
  - Bash: `emscripten-starter-pack/scripts/build.sh`
- Open: `http://localhost:8000/emscripten-starter-pack/web/index.html`

Troubleshooting:
- If you open via `file://`, you’ll see CORS errors like “CORS request not http”. Always use `http://localhost`.
- In DevTools Network tab, ensure `.wasm` files return 200 and paths match the HTML.

---

# Emscripten SDK (concise)
- Install: https://emscripten.org/docs/getting_started/downloads.html
- Verify: run `emcc -v` after loading `emsdk_env.sh` or `emsdk_env.ps1`.
- Gotchas:
  - Load the env script in each new shell or add to your profile.
  - Serve over HTTP (not `file://`) so the browser can fetch `.wasm`.
  - Windows Git SSL: `git config --global http.sslBackend schannel` helps in corporate networks.
  - Proxies/firewalls can block downloads; configure proxy or retry on a different network.
  - Export names: `-s EXPORTED_FUNCTIONS=_add` exports `_add`; `-Wl,--export=add_and_log` exports `add_and_log`.

---


## Coming Next: Part II Teaser
- Pyodide basics: loading the runtime, initializing once, and keeping it responsive (Web Worker recommended).
- JS <-> Python bridge: pass values, call functions, exchange structured data (JSON, typed arrays), and handle errors.
- Installing packages: use `micropip` for pure‑Python wheels; discuss constraints and practical workarounds for heavy native deps.
- Safety & limits: timeouts, resource caps, and sandboxing patterns for executing LLM‑generated Python.
- Express integration: a minimal Node/Express layer to serve Pyodide assets, proxy data, and expose simple endpoints for code execution.
- Caching & startup: CDN and HTTP caching, pre‑warming, and reducing cold‑start latency.
- Performance tips: moving work to a Worker, batching calls, and zero‑copy transfers where possible.

