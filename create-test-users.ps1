# Refresh PATH
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Creating Test Users" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Base URL
$baseUrl = "http://localhost:5000/api"

# Create Doctor
Write-Host "Creating Doctor account..." -ForegroundColor Yellow
$doctorData = @{
    name = "Dr. Sarah Smith"
    email = "doctor@test.com"
    password = "doctor123"
    role = "doctor"
    phone = "1234567890"
} | ConvertTo-Json

try {
    $doctorResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $doctorData -ContentType "application/json"
    Write-Host "✅ Doctor created successfully!" -ForegroundColor Green
    Write-Host "   Email: doctor@test.com" -ForegroundColor White
    Write-Host "   Password: doctor123" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "⚠️  Doctor account might already exist or error occurred" -ForegroundColor Yellow
    Write-Host "   Try logging in with: doctor@test.com / doctor123" -ForegroundColor White
    Write-Host ""
}

# Create Nurse
Write-Host "Creating Nurse account..." -ForegroundColor Yellow
$nurseData = @{
    name = "Nurse Jane Wilson"
    email = "nurse@test.com"
    password = "nurse123"
    role = "nurse"
    phone = "0987654321"
} | ConvertTo-Json

try {
    $nurseResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $nurseData -ContentType "application/json"
    Write-Host "✅ Nurse created successfully!" -ForegroundColor Green
    Write-Host "   Email: nurse@test.com" -ForegroundColor White
    Write-Host "   Password: nurse123" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "⚠️  Nurse account might already exist or error occurred" -ForegroundColor Yellow
    Write-Host "   Try logging in with: nurse@test.com / nurse123" -ForegroundColor White
    Write-Host ""
}

# Create Patient
Write-Host "Creating Patient account..." -ForegroundColor Yellow
$patientData = @{
    name = "John Doe"
    email = "patient@test.com"
    password = "patient123"
    role = "patient"
    phone = "5555555555"
} | ConvertTo-Json

try {
    $patientResponse = Invoke-RestMethod -Uri "$baseUrl/auth/register" -Method Post -Body $patientData -ContentType "application/json"
    Write-Host "✅ Patient created successfully!" -ForegroundColor Green
    Write-Host "   Email: patient@test.com" -ForegroundColor White
    Write-Host "   Password: patient123" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "⚠️  Patient account might already exist or error occurred" -ForegroundColor Yellow
    Write-Host "   Try logging in with: patient@test.com / patient123" -ForegroundColor White
    Write-Host ""
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Test Accounts Summary" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Doctor:" -ForegroundColor Cyan
Write-Host "  Email: doctor@test.com" -ForegroundColor White
Write-Host "  Password: doctor123" -ForegroundColor White
Write-Host ""
Write-Host "Nurse:" -ForegroundColor Cyan
Write-Host "  Email: nurse@test.com" -ForegroundColor White
Write-Host "  Password: nurse123" -ForegroundColor White
Write-Host ""
Write-Host "Patient:" -ForegroundColor Cyan
Write-Host "  Email: patient@test.com" -ForegroundColor White
Write-Host "  Password: patient123" -ForegroundColor White
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "You can now log in with any of these accounts!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
