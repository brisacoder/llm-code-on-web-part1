# Installing the Emscripten SDK (emsdk) on Ubuntu and Windows

The Emscripten SDK (emsdk) provides the toolchain to compile C/C++ to WebAssembly.
Follow these detailed steps. If anything fails, re-run the same command after fixing the noted issue.

---

## Ubuntu (Linux)

1) **Install dependencies**

```bash
sudo apt update
sudo apt install -y git cmake build-essential python3 python3-pip
```

2) **Clone emsdk**

```bash
cd ~
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
```

3) **Install & activate latest**

```bash
./emsdk install latest
./emsdk activate latest
```

> If you see `Permission denied`, make script executable: `chmod +x emsdk`.

4) **Set environment (per shell)**

```bash
source ./emsdk_env.sh
```

To make it permanent (bash):

```bash
echo 'source "$HOME/emsdk/emsdk_env.sh"' >> ~/.bashrc
```

5) **Verify**

```bash
emcc -v
```

---

## Windows (PowerShell)

1) **Install Git**: https://git-scm.com/download/win  
2) **Install Python 3** and tick "Add Python to PATH": https://www.python.org/downloads/windows/

3) **Clone emsdk**

```powershell
cd $HOME
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
```

If SSL issues occur:
```powershell
git config --global http.sslBackend schannel
```

4) **Install & activate latest**

```powershell
.\emsdk install latest
.\emsdk activate latest
```

5) **Set environment (per shell)**

```powershell
.\emsdk_env.ps1
```

To persist PATH, you can add `%EMSDK%\upstream\emscripten` to PATH in
**System Properties → Advanced → Environment Variables**. Prefer running `. \emsdk_env.ps1`
in each new PowerShell to keep it simple for class.

6) **Verify**

```powershell
emcc -v
```

---

## Quick sanity test (both OS)

Create a file `hello.c`:

```c
#include <stdio.h>
int main(void) {
  printf("Hello, WebAssembly!\n");
  return 0;
}
```

Compile and run in a browser:

```bash
emcc hello.c -o hello.html
# Serve the directory (example using Python)
python3 -m http.server 8080
# Visit http://localhost:8080/hello.html
```

If the page is blank, open the **browser devtools console** to view program output.
