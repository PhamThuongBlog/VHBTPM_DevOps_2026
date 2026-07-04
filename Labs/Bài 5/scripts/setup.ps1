# ============================================================
# setup.ps1 — Script cài đặt môi trường Lab 5 (Windows)
# ============================================================
# Usage: .\setup.ps1

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Lab 5 — Setup Git & GitHub Environment" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. Check Git ---
Write-Host "[1/3] Checking Git..." -ForegroundColor Yellow
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "Git chưa được cài đặt. Đang tải..." -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/downloads" -ForegroundColor Yellow
    $url = "https://github.com/git-for-windows/git/releases/download/v2.45.0.windows.1/Git-2.45.0-64-bit.exe"
    $output = "$env:TEMP\Git-Installer.exe"
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process -FilePath $output -Wait
    Remove-Item $output
    Write-Host "Git installed. Please restart your terminal." -ForegroundColor Green
} else {
    Write-Host "Git found: $(git --version)" -ForegroundColor Green
}

# --- 2. Configure Git ---
Write-Host "[2/3] Configure Git..." -ForegroundColor Yellow
$currentName = git config --global user.name 2>$null
$currentEmail = git config --global user.email 2>$null

if (-not $currentName) {
    $name = Read-Host "Enter your full name (e.g., Nguyen Van A)"
    git config --global user.name $name
    Write-Host "  user.name = $name" -ForegroundColor Green
} else {
    Write-Host "  user.name = $currentName (already configured)" -ForegroundColor Green
}

if (-not $currentEmail) {
    $email = Read-Host "Enter your email"
    git config --global user.email $email
    Write-Host "  user.email = $email" -ForegroundColor Green
} else {
    Write-Host "  user.email = $currentEmail (already configured)" -ForegroundColor Green
}

# Set default branch and editor
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
Write-Host "  init.defaultBranch = main" -ForegroundColor Green
Write-Host "  core.editor = code --wait" -ForegroundColor Green

# --- 3. Check GitHub ---
Write-Host "[3/3] GitHub Ready?" -ForegroundColor Yellow
Write-Host "Make sure you have:" -ForegroundColor White
Write-Host "  ✅ GitHub account (github.com)" -ForegroundColor White
Write-Host "  ✅ Personal Access Token (Settings → Developer settings → PAT)" -ForegroundColor White
Write-Host ""
Write-Host "Test your connection:" -ForegroundColor Yellow
Write-Host "  ssh -T git@github.com    (if using SSH)" -ForegroundColor White
Write-Host "  or use HTTPS + Token when pushing" -ForegroundColor White

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  SETUP HOÀN TẤT!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
