# ============================================================
# setup.ps1 — Script cài đặt môi trường Lab 1 (Windows)
# ============================================================
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Lab 1 — Setup DevOps Environment" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/2] Checking Git..." -ForegroundColor Yellow
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "Git not found. Download: https://git-scm.com/downloads" -ForegroundColor Red
    exit 1
}
Write-Host "Git: $(git --version)" -ForegroundColor Green

Write-Host "[2/2] GitHub Ready?" -ForegroundColor Yellow
Write-Host "Make sure you have:" -ForegroundColor White
Write-Host "  ✅ GitHub account (github.com)" -ForegroundColor White
Write-Host "  ✅ Git configured (git config --global user.name/email)" -ForegroundColor White
Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
