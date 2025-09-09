# Emscripten Starter Pack – Build & Run

Use the root-level INSTALL guide for SDK setup and serving. This page only covers building and running the samples in this `emscripten-starter-pack/` folder.

See: `../../install.md`

---

Prerequisite: Emscripten SDK installed and environment loaded (`emcc` on PATH).

Build the demos:

- PowerShell (Windows): `scripts/build.ps1`
- Bash (Linux/macOS): `scripts/build.sh`

Serve and open:

- Start a static server from the repo root (examples in `../../install.md`).
- Visit `http://localhost:8000/emscripten-starter-pack/web/index.html`.

Notes:

- The page loads `dist/hello_export.wasm` and calls its `_add` export.
- Do not open via `file://` — browsers block `fetch` from file origins.

