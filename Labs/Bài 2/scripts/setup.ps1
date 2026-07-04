# ============================================================
# setup.ps1 — Script cài đặt môi trường Lab 2 (Windows)
# ============================================================
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Lab 2 — Setup DevOps Environment" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "[1/3] Checking Git..." -ForegroundColor Yellow
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) { Write-Host "Git: $(git --version)" -ForegroundColor Green }

Write-Host "[2/3] Checking Docker..." -ForegroundColor Yellow
$docker = Get-Command docker -ErrorAction SilentlyContinue
if ($docker) { Write-Host "Docker: $(docker --version)" -ForegroundColor Green }

Write-Host "[3/3] Checking VS Code..." -ForegroundColor Yellow
$code = Get-Command code -ErrorAction SilentlyContinue
if ($code) { Write-Host "VS Code found." -ForegroundColor Green }

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host "Next: Follow Lab2_HuongDan.md" -ForegroundColor White
