# Refresh PATH environment variable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Hybrid Connect - Mobile App" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Flutter version
Write-Host "Checking Flutter installation..." -ForegroundColor Yellow
flutter --version
Write-Host ""

# Run the app
Write-Host "Starting Flutter app in Chrome..." -ForegroundColor Yellow
Write-Host ""
flutter run -d chrome
