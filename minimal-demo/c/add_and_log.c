// Minimal Wasm module for the JS ↔ Wasm round trip
// - Exports: add_and_log(a, b) → i32
// - Imports: env.log_i32(i32) provided by JavaScript

extern void log_i32(int);

int add_and_log(int a, int b) {
  int s = a + b;
  // Call back into JS via imported function
  log_i32(s);
  return s;
}
