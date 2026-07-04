# ============================================================
# setup.ps1 — Script cài đặt môi trường Lab 8 (Windows)
# ============================================================
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Lab 8 — Setup Docker + Jenkins CD Environment" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "[1/3] Checking Docker..." -ForegroundColor Yellow
docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR: Start Docker Desktop!" -ForegroundColor Red; exit 1 }
Write-Host "Docker: $(docker --version)" -ForegroundColor Green

Write-Host "[2/3] Checking Docker Compose..." -ForegroundColor Yellow
Write-Host "Compose: $(docker compose version)" -ForegroundColor Green

Write-Host "[3/3] Docker Hub Ready?" -ForegroundColor Yellow
Write-Host "Make sure you have Docker Hub account + docker login" -ForegroundColor White

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
