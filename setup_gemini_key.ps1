# Creates gemini_api_key.local.dart from the team template (shared key included).
$example = Join-Path $PSScriptRoot "lib\config\gemini_api_key.local.example.dart"
$local = Join-Path $PSScriptRoot "lib\config\gemini_api_key.local.dart"

if (-not (Test-Path $example)) {
    Write-Error "Missing $example"
    exit 1
}

Copy-Item $example $local -Force
Write-Host "OK: lib\config\gemini_api_key.local.dart ready (team Gemini key)."
Write-Host "Next: flutter pub get"
Write-Host "      flutter run"
