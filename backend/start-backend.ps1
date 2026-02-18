# Refresh PATH environment variable
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Hybrid Connect - Backend Server" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check Node.js version
Write-Host "Checking Node.js installation..." -ForegroundColor Yellow
node --version
Write-Host ""

# Start the server
Write-Host "Starting backend server..." -ForegroundColor Yellow
Write-Host ""
node server.js
