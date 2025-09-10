Param()

$ErrorActionPreference = 'Stop'

Write-Host "Cleaning build artifacts..."

# Top-level demo artifacts
if (Test-Path 'web/dist') {
  Write-Host "- Removing web/dist/"
  Remove-Item -Recurse -Force 'web/dist'
}

# Starter pack artifacts
if (Test-Path 'emscripten-starter-pack/dist') {
  Write-Host "- Removing emscripten-starter-pack/dist/"
  Remove-Item -Recurse -Force 'emscripten-starter-pack/dist'
}

# Stray generated files accidentally placed in web/
$strays = @(
  'emscripten-starter-pack/web/hello_stdio.html',
  'emscripten-starter-pack/web/hello_stdio.js',
  'emscripten-starter-pack/web/hello_stdio.wasm'
)
foreach($f in $strays){ if(Test-Path $f){ Write-Host "- Removing stray $f"; Remove-Item -Force $f } }

Write-Host "Done."

