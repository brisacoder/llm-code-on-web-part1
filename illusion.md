graph TD
    A[Python code (CPython)] --> B[CPython runtime (C)]
    B --> C[Python C API and C extensions]
    C --> D[libc / POSIX API calls]
    D --> E[Emscripten shims or WASI libc]
    E --> F[WebAssembly module (.wasm)]
    F --> G[Wasm engine (JIT compiler)]
    G --> H[Host interface]
    H --> I[Browser: JS shims, virtual FS, IndexedDB]
    H --> J[WASI runtime: Wasmtime, Node, WasmEdge]
    I --> K[OS kernel and hardware]
    J --> K[OS kernel and hardware]

