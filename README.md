# WebAssembly– Roadmap

This repo takes you from “What is WebAssembly?” to two small, working browser demos. Use the Install & Run section below for setup and running.

## 0) Install & Run
- See Install & Run section below for SDK setup, local server, and quickstart
- `web/index.html`: minimal JS ↔ Wasm round-trip (build via `scripts/build_add_and_log.*`)

## 1) Foundations
- intro_to_wasm.md: how Wasm runs; imports/exports; browser vs Node/WASI

## 2) Architecture
- [OS Illusion stack (browser vs WASI)](intro_to_wasm.md#os-illusion-stack-view)
- [JS ↔ Wasm ↔ JS back-call and return values](intro_to_wasm.md#js-wasm-round-trip-browser)
- [Syscall Round Trip](intro_to_wasm.md#syscall-round-trip-sequence)

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
├─ intro_to_wasm.md
├─ README.md
└─ LICENSE / .gitignore
```

---

# Install & Run (Lecture Quickstart)

This guide has two parts:
- Quickstart to build and run the demos (with a local server).
- Detailed Emscripten SDK install steps for Windows and Linux.

---

## Quickstart: Run the Browser Demos

Prerequisites:
- Emscripten SDK installed and environment loaded so `emcc` is on PATH (see below if needed).
- A local static file server (browsers block `fetch` from `file://`).

Start a server from the repo root (pick one):
- Python: `python -m http.server 8000` (or `py -m http.server 8000` on Windows)
- Node: `npx serve .`
- VS Code: Live Server extension

1) Top-level JS ↔ Wasm demo
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

# Installing the Emscripten SDK (emsdk) on Ubuntu and Windows

The Emscripten SDK provides all the tools required to compile C/C++ (and other languages via LLVM) to WebAssembly (`.wasm`). It bundles `clang`, `node`, `python`, and utilities like `emcc`.

This guide walks you through installation on Ubuntu Linux and Windows. Each step is explicit, with troubleshooting notes included.

---

## 1. General Prerequisites

Emscripten requires:

* Git (to clone the SDK repository).
* Python 3 (used internally by emsdk).
* CMake (sometimes needed for building native dependencies).
* Sufficient disk space (≈ 2–3 GB).
* Internet access (the SDK downloads prebuilt toolchains).

Make sure your firewall or proxy settings allow GitHub downloads.

---

## 2. Installation on Ubuntu Linux

### Step 1: Install system dependencies

Open a terminal and install the basics:

```bash
sudo apt update
sudo apt install -y git cmake build-essential python3 python3-pip
```

**Pitfalls:**

* If you see `E: Unable to locate package`, make sure your `/etc/apt/sources.list` is not stale. Run `sudo apt update` first.
* Ubuntu 20.04 or later is recommended. Older releases may ship outdated `cmake`/`python`.

---

### Step 2: Clone the emsdk repository

Choose a directory where you want emsdk to live (e.g., `$HOME/emsdk`):

```bash
cd ~
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
```

---

### Step 3: Install and activate the latest SDK

Run the following:

```bash
./emsdk install latest
./emsdk activate latest
```

This will:

* Download the latest LLVM/Clang toolchain compiled for Linux.
* Install `node` and `python` if not already present.
* Write an `emsdk_env.sh` file to configure your environment.

**Pitfalls:**

* If `./emsdk` fails with `Permission denied`, ensure the script is executable:
  `chmod +x emsdk`.
* On slow connections, large downloads may timeout. Just re-run `./emsdk install latest`.

---

### Step 4: Set environment variables

Each time you open a new shell, you need to load the environment:

```bash
source ./emsdk_env.sh
```

To make it permanent, add this line to `~/.bashrc` or `~/.zshrc`:

```bash
source $HOME/emsdk/emsdk_env.sh
```

---

### Step 5: Verify installation

Run:

```bash
emcc -v
```

Expected output:

* Version info for `emcc`.
* Confirmation of the LLVM backend.

If you see “command not found”, it means `emsdk_env.sh` was not sourced.

---

## 3. Installation on Windows

On Windows, emsdk works best using PowerShell or Git Bash. These instructions assume PowerShell.

### Step 1: Install Git for Windows

* Download from: https://git-scm.com/download/win
* During install, select "Git from the command line and also from 3rd-party software".

**Pitfall:** If `git` isn’t recognized, restart PowerShell after installation.

---

### Step 2: Install Python

* Download Python 3 from: https://www.python.org/downloads/windows/
* During installation:

  * Check "Add Python to PATH".
  * Install for all users if possible.

Verify with:

```powershell
python --version
```

---

### Step 3: Clone the emsdk repository

In PowerShell:

```powershell
cd $HOME
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
```

If you see errors like SSL certificate problem, configure Git with:

```powershell
git config --global http.sslBackend schannel
```

---

### Step 4: Install and activate

Run:

```powershell
.\emsdk install latest
.\emsdk activate latest
```

This will fetch the prebuilt LLVM/Clang toolchain for Windows.

---

### Step 5: Set environment variables

Each new shell must load the environment. Run:

```powershell
.\emsdk_env.ps1
```

To make it permanent run with Admin privileges

```powershell
.\emsdk.ps1 activate latest --system
```

---

### Step 6: Verify installation

In a fresh PowerShell window:

```powershell
emcc -v
```
You should see something like:

```powershell
emcc (Emscripten gcc/clang-like replacement + linker emulating GNU ld) 4.0.14 (96371ed7888fc78c040179f4d4faa82a6a07a116)
clang version 22.0.0git (https:/github.com/llvm/llvm-project 1cc84bcc08f723a6ba9d845c3fed1777547f45f9)
Target: wasm32-unknown-emscripten
Thread model: posix
```

If not:

* You might need a reboot.
* Ensure you ran `.\emsdk_env.ps1`.
* Check `PATH` includes Emscripten directories.

---

## 4. Common Issues and Fixes

| Symptom                   | Likely Cause                                                        | Fix                                                                   |
| ------------------------- | ------------------------------------------------------------------- | --------------------------------------------------------------------- |
| `emcc: command not found` | Did not source `emsdk_env.sh` (Linux) or `emsdk_env.ps1` (Windows). | Re-run the script or add to shell profile.                            |
| Download stuck at 0%      | Firewall/proxy blocking GitHub downloads.                           | Configure proxy or use VPN.                                           |
| Wrong Python version      | Old `python` alias points to Python 2.                              | Use `python3` or adjust PATH.                                         |
| CMake not found           | Not installed system-wide.                                          | `sudo apt install cmake` (Linux) or install from cmake.org (Windows). |
| “Permission denied”       | Script not executable (Linux).                                      | `chmod +x emsdk` before running.                                      |

---

## 5. Quick Sanity Check

Use the existing sample at `emscripten-starter-pack/c/hello_stdio.c`.

Option A — use the provided build script (generates both demos under `emscripten-starter-pack/dist/`):

```bash
emscripten-starter-pack/scripts/build.sh       # bash
# or
powershell -File emscripten-starter-pack/scripts/build.ps1
```

Option B — compile just the printf demo manually to `dist/hello.html`:

```bash
emcc emscripten-starter-pack/c/hello_stdio.c -o emscripten-starter-pack/dist/hello.html
```

Serve the repo root and open the generated page (serving is required so the browser can fetch the `.wasm` file):

```bash
python -m http.server 8000
# then visit
http://localhost:8000/emscripten-starter-pack/dist/hello.html
```

On Windows PowerShell, the same commands work if your environment is loaded (after running `./emsdk_env.ps1`).

Note: Opening via `file://` will often fail because the page fetches the `.wasm` file.
Use a local HTTP server so the browser allows the request.

---

## 6. References

* Official docs: https://emscripten.org/docs/getting_started/downloads.html
* GitHub repo: https://github.com/emscripten-core/emsdk

---

Lecture tip:
When demonstrating live, show the difference between:

* Running `emcc` without sourcing env (error).
* Then sourcing env and re-running (success).
  It illustrates why environment setup matters.
