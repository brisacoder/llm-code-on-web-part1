// A small example that exports `add` to JS.
// Flags used (see build scripts):
//   -s STANDALONE_WASM=1      : produces a self-contained .wasm with no JS glue
//   -s EXPORTED_FUNCTIONS=_add: makes the symbol visible as an export
//   --no-entry                : no main(); we only export functions

int add(int a, int b) {
    return a + b;
}
