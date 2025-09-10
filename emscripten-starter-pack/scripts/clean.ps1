Param()

$ErrorActionPreference = 'Stop'

# Make script location the working directory so it can be run from anywhere
$scriptDir = Split-Path -Parent $PSCommandPath
$packRoot  = Split-Path -Parent $scriptDir

Write-Host "Cleaning Emscripten starter-pack artifacts..."

try {
  Push-Location $packRoot

  # dist outputs
  if (Test-Path 'dist') {
    Write-Host "- Removing dist/"
    Remove-Item -Recurse -Force 'dist'
  }

  # Stray generated files accidentally placed under web/
  $strays = @(
    'web/hello_stdio.html',
    'web/hello_stdio.js',
    'web/hello_stdio.wasm',
    'web/hello_export.wasm'
  )
  foreach ($f in $strays) {
    if (Test-Path $f) {
      Write-Host "- Removing stray $f"
      Remove-Item -Force $f
    }
  }
}
finally {
  Pop-Location
  Write-Host "Done."
}
