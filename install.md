# Installing the Emscripten SDK (emsdk) on Ubuntu and Windows

The **Emscripten SDK** provides all the tools required to compile C/C++ (and other languages via LLVM) to **WebAssembly** (`.wasm`). It bundles `clang`, `node`, `python`, and utilities like `emcc`.

This guide walks you through installation on **Ubuntu Linux** and **Windows**. Each step is explicit, with troubleshooting notes included.

---

## 1. General Prerequisites

Emscripten requires:

* **Git** (to clone the SDK repository).
* **Python 3** (used internally by emsdk).
* **CMake** (sometimes needed for building native dependencies).
* **Sufficient disk space** (≈ 2–3 GB).
* **Internet access** (the SDK downloads prebuilt toolchains).

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

On Windows, emsdk works best using **PowerShell** or **Git Bash**. These instructions assume **PowerShell**.

### Step 1: Install Git for Windows

* Download from: [https://git-scm.com/download/win](https://git-scm.com/download/win)
* During install, select *"Git from the command line and also from 3rd-party software"*.

**Pitfall:** If `git` isn’t recognized, restart PowerShell after installation.

---

### Step 2: Install Python

* Download Python 3 from: [https://www.python.org/downloads/windows/](https://www.python.org/downloads/windows/)
* During installation:

  * ✅ Check *"Add Python to PATH"*.
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

If you see errors like *SSL certificate problem*, configure Git with:

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

To make it permanent:

* Right-click **This PC → Properties → Advanced system settings → Environment Variables**.
* Add a new **User variable**:

  * Name: `EMSDK`
  * Value: `C:\Users\<YourName>\emsdk`
* Append `%EMSDK%\upstream\emscripten` and `%EMSDK%\node\12.x.x_64bit\bin` to your `PATH`.

**Pitfall:** Forgetting this means `emcc` will not be found after reboot.

---

### Step 6: Verify installation

In a fresh PowerShell window:

```powershell
emcc -v
```

You should see version information. If not:

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

## 5. Quick Sanity Test

Create a file `hello.c`:

```c
#include <stdio.h>
int main() {
  printf("Hello, WebAssembly!\\n");
  return 0;
}
```

Compile with:

```bash
emcc hello.c -o hello.html
```

Open `hello.html` in a browser. You should see `"Hello, WebAssembly!"` printed.

---

## 6. References

* Official docs: [https://emscripten.org/docs/getting\_started/downloads.html](https://emscripten.org/docs/getting_started/downloads.html)
* GitHub repo: [https://github.com/emscripten-core/emsdk](https://github.com/emscripten-core/emsdk)

---

📌 **Lecture Tip:**
When demonstrating live, show the difference between:

* Running `emcc` **without** sourcing env (error).
* Then sourcing env and re-running (success).
  It illustrates *why* environment setup matters.

