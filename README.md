# Running LLM Code on the Web: Wasm/Pyodide, Part I

This repo is Part I of a 3-part series on running LLM-generated code on the web. Here we focus on Wasm fundamentals and two minimal browser demos. Use the Install & Run section below for setup and running.

## Series roadmap

- **Part I (this repo)**: Wasm basics + minimal JS ↔ Wasm demos
- **Part II**: Pyodide in the browser + Node/Express integration for running Python (LLM‑generated) safely and interactively
- **Part III**: Hardening and shipping - packaging strategies, caching, performance tips, and end-to-end workflows

## Why run LLM-generated Data Science code in the browser (Pyodide/Wasm)?

- **Zero install friction**: users open a link and run code. No Conda, no system Python, no native compilers.
- **Strong sandboxing by default**: browser/Wasm isolates execution. No file system or network unless you explicitly allow it.
- **Privacy by design**: sensitive data can stay on-device; small and medium workloads execute locally without uploading datasets.
- **Reproducibility that travels**: ship a pinned package set (micropip) and deterministic init code so notebooks and snippets behave the same on macOS/Windows/Linux.
- **Cost and scale**: shift interactive compute to the client; reserve servers for heavy jobs or collaboration.
- **Great UX for iteration**: fast edit-run loops, rich visualizations in-canvas/DOM, and JS ↔ Python data flow for UI controls.
- **Portability**: the exact same experience across devices and OSes, including managed desktops where installs are restricted.
- **Governance-friendly**: narrow, capability-based access makes security reviews simpler than desktop installs.
- **Works offline/edge**: after assets are cached, keep running even with spotty connectivity.

## Know the limits

- Heavy native dependencies (C-extensions) may not be available as pure-Python wheels; design around them or offload to a service.
- Memory/CPU are bounded by the browser; long-running or big-data jobs still belong on a backend.

## Automation and Server Mode (Node.js)

- **Programmatic execution**: have an LLM generate Python, send it to a REST endpoint, execute in a controlled Pyodide runtime, and return results as JSON (stdout/stderr, figures, data frames serialized).
- **Simple API shape**: POST /execute { code, inputs } to run; GET /runs/:id to fetch status/artifacts; optional SSE/WebSocket for live logs/streams.
- **Run on Node.js to bypass browser limits**: execute the same Pyodide code under Node (server-side) when you need more memory/CPU, headless batch jobs, or trusted network/file access.
- **Leverage the Node ecosystem**: authentication (JWT/OAuth), authorization/RBAC, rate limiting, CSRF, routing/middleware, logging/metrics, retries/timeouts, job queues, and caching.
- **Persist outputs and ensure traceability**: mount Pyodide's virtual FS to persistent storage (IndexedDB in the browser; host disk in Node) to save Matplotlib/Seaborn plots, logs, and intermediate files. Store code + inputs + outputs together for reproducibility/auditing.

## Why WebAssembly Matters

WebAssembly powers production applications like:
- **Figma** – Design tool performance comparable to native apps
- **AutoCAD Web** – Full CAD software running in browsers
- **Google Earth** – 3D globe rendering at 60fps
- **Photoshop Web** – Complex image processing in the browser
- **Unity Games** – Console-quality games without plugins

## Foundations

### What WebAssembly is
WebAssembly (Wasm) is a **portable, sandboxed, low-level binary format**. It lets you run compiled code (C/C++/Rust/Zig, etc.) safely in:
- **Browsers** (integrated with the JavaScript engine)
- **Servers/CLIs** via runtimes (Node's `node:wasi`, Wasmtime, Wasmer, WasmEdge)

Think of it as **"LLVM-like bytecode for the web and beyond"** with strict safety guarantees and predictable performance characteristics.

### Why people use it
- **Performance**: Ahead-of-time or JIT compiled to native CPU instructions.
- **Portability**: Same `.wasm` can run across OSes/CPUs when a runtime exists.
- **Safety**: Memory-safe, capability-based host access (you only get what's imported).

### How execution works (high level)

```mermaid
graph TD
  A[Source languages] --> B[Wasm binary]
  B --> C[Wasm engine]
  C --> D[Native code via JIT or AOT]
  D --> E[CPU executes inside sandbox]
  C --> F[Host imports: files, time, console]
```

* **Imports/Exports**: Wasm modules **export** functions and **import** host functions (JS in browsers; WASI or custom hosts in runtimes).
* **Memory model**: A linear memory (resizable array of bytes). JS can view it as `ArrayBuffer`; native code uses pointers/offsets.
* **Sandbox**: No raw syscalls; all host access is explicitly imported.

### Emscripten vs. WASI — What They Are and When to Use Them

#### What is **Emscripten**?

* **Definition**: A compiler toolchain (built on LLVM/Clang) that takes C/C++ (and anything that compiles to LLVM IR) and outputs WebAssembly plus a layer of JavaScript "glue code."
* **How it works**:
  * Replaces the C standard library (`libc`) calls with **JavaScript shims** (virtual filesystem, sockets via WebSockets, stdout → browser console).
  * Lets legacy codebases believe they are running on a POSIX-like OS, even though they're inside a browser sandbox.
* **Use cases**: Porting large C/C++ projects to the web (e.g., CPython → Pyodide, SDL games, OpenCV in browser, NumPy).
* **Mental model**: *Fake a Unix-like OS in the browser by redirecting syscalls through JavaScript.*

#### What is **WASI (WebAssembly System Interface)**?

* **Definition**: A standardized set of system calls for WebAssembly outside the browser.
* **How it works**:
  * Defines a portable API (`wasi_snapshot_preview1`) for files, directories, clocks, randomness, args/env, etc.
  * Runtimes (like Wasmtime, Node's `node:wasi`, Wasmer, WasmEdge) implement those APIs and forward them safely to the host OS.
* **Use cases**: Headless/server-side Wasm programs, CLI tools, micro-VMs at the edge, lightweight container replacements.
* **Mental model**: *Give Wasm modules a minimal, standardized "operating system" that works across all runtimes.*

#### Comparison — When to Choose Each

| Aspect             | **Emscripten**                              | **WASI**                                     |
| ------------------ | ------------------------------------------- | -------------------------------------------- |
| Primary target     | **Browsers** (integrated with JS/DOM)       | **Servers / CLIs / Edge runtimes**           |
| System calls       | Shimmed through **JavaScript**              | Standardized **portable syscalls**           |
| Filesystem         | Virtual FS, IndexedDB, in-memory            | Real host directories (sandboxed pre-opens)  |
| Networking         | WebSockets, XHR (emulated sockets)          | Host TCP/UDP (if runtime implements)         |
| Typical toolchains | `emcc` (Emscripten compiler)                | Clang, Rust, Zig targeting `wasm32-wasi`     |
| Best for…          | Bringing **existing C/C++ code** to the web | Writing **new headless/server apps** in Wasm |

**One-liner takeaway:**
* Use **Emscripten** when you want Wasm in the **browser** and need JS shims for POSIX-style code.
* Use **WASI** when you want Wasm on the **server/edge** with a clean, portable syscall layer.

### Browser vs. Node (mental model)

* **Browser path**: JS/DOM ↔ Wasm. You pass imports from JS; Wasm calls them. Files/sockets are emulated or backed by browser storage/APIs.
* **Node/WASI path**: Host provides WASI imports; module starts like a tiny process with sandboxed pre-opened directories and a minimal syscall surface.

### Feature notes (quick)

* **SIMD**: Widely supported in modern engines for data-parallel speedups.
* **Threads**: In browsers, requires cross-origin isolation (COOP/COEP). In WASI runtimes, depends on host support.
* **Exceptions, reference types, GC**: Advancing steadily; check engine/runtime versions.

### Typical toolchains

* **C/C++**: Emscripten (`emcc`) for browser; Clang + WASI sysroot for WASI.
* **Rust**: Targets `wasm32-unknown-unknown` (browser) or `wasm32-wasi` (WASI). Tooling: `wasm-bindgen`, `wasm-pack`.
* **Zig/Clang**: Direct to `wasm32-wasi` for minimalist builds.

### Mini-FAQ

* **"Is Wasm tied to one CPU?"** No. Engines JIT/AOT to your CPU (x86-64, ARM64, etc.). The same `.wasm` runs where an engine exists.
* **"Can Python run in Wasm?"** Yes. Via Emscripten (Pyodide) or emerging WASI targets. Many POSIX calls are emulated in-browser.
* **"Do I need JS?"** In browsers, yes (for orchestration/imports). In Node/WASI, you can be fully headless.

## Architecture

### OS Illusion Stack

High-level runtimes think they run atop an OS. In the browser, Emscripten provides JS shims and a virtual filesystem; in servers, WASI-capable runtimes expose a minimal, portable syscall layer.

```mermaid
graph TD
  A["Python (CPython)"] --> B["CPython runtime (C)"]
  B --> C["Python C API and C extensions"]
  C --> D["libc / POSIX"]
  D --> E["Emscripten shims or WASI libc"]
  E --> F["WebAssembly (.wasm)"]
  F --> G["Wasm engine / JIT"]
  G --> H["Host interface"]
  H --> I["Browser: JS shims, virtual FS, IndexedDB"]
  H --> J["WASI runtime: Wasmtime, Node, WasmEdge"]
  I --> K["OS kernel / hardware"]
  J --> K["OS kernel / hardware"]
```

Key takeaways:
- Browser path: libc calls funnel into JS glue (Emscripten) and browser APIs; no raw syscalls.
- WASI path: libc targets WASI; the runtime mediates access to real OS resources via sandboxed pre-opens.

### JS ↔ Wasm ↔ JS Round Trip

This diagram shows how JavaScript calls WebAssembly, which can call back into JavaScript, and return values:

```mermaid
sequenceDiagram
    autonumber
    participant User as User
    participant DOM as Browser/DOM
    participant JS as JavaScript (V8/SpiderMonkey)
    participant Wasm as WebAssembly Runtime
    participant JIT as JIT/Codegen
    participant CPU as CPU (OS scheduler)

    User->>DOM: Click "Run"
    DOM->>JS: onclick handler
    JS->>Wasm: instance.exports.add_and_log(7, 5)
    Note right of Wasm: Validate & call compiled function
    Wasm->>JIT: Use precompiled machine code
    JIT->>CPU: Execute native instructions
    CPU-->>Wasm: Produce sum = 12

    Note over Wasm,JS: Back path: Wasm calls an imported JS function
    Wasm->>JS: env.log_i32(12)
    JS->>DOM: console.log("WASM says:", 12)

    Note over Wasm: Return to caller
    Wasm-->>JS: return 12
    JS->>DOM: Render result "12"
```

### Syscall Round Trip Sequence

How a single `open()` flows from user code down to the host and back:

```mermaid
sequenceDiagram
  autonumber
  participant Py as Python code
  participant CP as CPython runtime
  participant Libc as libc
  participant Glue as Emscripten/WASI glue
  participant Wasm as Wasm engine
  participant Host as Host interface
  participant OS as OS kernel

  Py->>CP: open("data.txt")
  CP->>Libc: fopen / open
  Libc->>Glue: shimmed call
  Glue->>Wasm: enter Wasm boundary
  Wasm->>Host: imported function
  alt Browser build
    Host->>OS: storage API / IndexedDB
  else WASI runtime
    Host->>OS: native syscall (sandboxed)
  end
  OS-->>Host: file handle
  Host-->>Wasm: return value
  Wasm-->>Glue: pass back result
  Glue-->>Libc: libc return
  Libc-->>CP: fd or FILE*
  CP-->>Py: Python file object
```

Notes:
- In browsers, the "OS" is emulated via JS; persistence often uses IndexedDB or in-memory FS.
- In WASI, access is explicit and limited; directories must be pre-opened by the host.

---

# Install & Run (Quickstart)
# Install & Run (Quickstart)

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

1) Minimal JS <-> Wasm demo
- Build the Wasm once:
  - PowerShell: `scripts/build_add_and_log.ps1`
  - Bash: `scripts/build_add_and_log.sh`
- Open: `http://localhost:8000/web/index.html`
- Click "Run". You should see console log "WASM says: 12" and "Result: 12".

2) Emscripten Starter Pack demo
- Build:
  - PowerShell: `emscripten-starter-pack/scripts/build.ps1`
  - Bash: `emscripten-starter-pack/scripts/build.sh`
- Open: `http://localhost:8000/emscripten-starter-pack/web/index.html`

Troubleshooting:
- If you open via `file://`, you'll see CORS errors like "CORS request not http". Always use `http://localhost`.
- In DevTools Network tab, ensure `.wasm` files return 200 and paths match the HTML.

---

# Installing the Emscripten SDK (emsdk)

The Emscripten SDK provides all the tools required to compile C/C++ to WebAssembly (`.wasm`). It bundles `clang`, `node`, `python`, and utilities like `emcc`.

Prerequisites: Git, Python 3, and ~2GB disk space.

---

## Linux/macOS

```bash
# Clone and setup
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest

# Load environment (each new shell)
source ./emsdk_env.sh

# Verify
emcc -v
```

To make permanent, add `source $HOME/emsdk/emsdk_env.sh` to `~/.bashrc` or `~/.zshrc`.

## Windows (PowerShell)

```powershell
# Clone and setup
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
.\emsdk install latest
.\emsdk activate latest

# Load environment (each new shell)
.\emsdk_env.ps1

# Verify
emcc -v
```

To make permanent, run `.\emsdk.ps1 activate latest --system` with Admin privileges.

---

## Common Issues

| Issue | Fix |
|-------|-----|
| `emcc: command not found` | Run `source ./emsdk_env.sh` (Linux) or `.\emsdk_env.ps1` (Windows) |
| Download stuck | Check firewall/proxy settings for GitHub access |
| "Permission denied" (Linux) | Run `chmod +x emsdk` |

---

## Test Installation

```bash
# Build a sample
emcc emscripten-starter-pack/c/hello_stdio.c -o test.html

# Serve and view
python -m http.server 8000
# Open: http://localhost:8000/test.html
```

---

## References

* [Emscripten docs](https://emscripten.org/docs/getting_started/downloads.html)
* [emsdk GitHub](https://github.com/emscripten-core/emsdk)

---

# Demos

## What's Available
- **Top-level demo**: build `web/add_and_log.wasm` with `scripts/build_add_and_log.ps1` (or `.sh`), then open `web/index.html` via a local server
- **Emscripten pack demo**: run `emscripten-starter-pack/scripts/build.*` and open `emscripten-starter-pack/web/index.html`

## Repository Layout
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
├─ intro_to_wasm.md
├─ README.md
└─ LICENSE / .gitignore
```
