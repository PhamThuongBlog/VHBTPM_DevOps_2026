# ============================================================
# setup.ps1 — Script cài đặt môi trường Lab 3 (Windows)
# ============================================================
# Chạy bằng PowerShell với quyền Administrator
# Usage: .\setup.ps1

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Lab 3 - Cài đặt Môi trường Terraform + AWS" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. Kiểm tra Chocolatey ---
Write-Host "[1/4] Kiểm tra Chocolatey..." -ForegroundColor Yellow
$choco = Get-Command choco -ErrorAction SilentlyContinue
if (-not $choco) {
    Write-Host "Chocolatey chưa được cài đặt. Đang cài đặt..." -ForegroundColor Red
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    Write-Host "Chocolatey đã cài đặt xong." -ForegroundColor Green
} else {
    Write-Host "Chocolatey đã có sẵn." -ForegroundColor Green
}

# --- 2. Cài đặt Terraform ---
Write-Host "[2/4] Cài đặt Terraform..." -ForegroundColor Yellow
$terraform = Get-Command terraform -ErrorAction SilentlyContinue
if (-not $terraform) {
    choco install terraform -y
    Write-Host "Terraform đã cài đặt xong." -ForegroundColor Green
} else {
    Write-Host "Terraform đã có sẵn." -ForegroundColor Green
}

# --- 3. Cài đặt AWS CLI ---
Write-Host "[3/4] Cài đặt AWS CLI..." -ForegroundColor Yellow
$aws = Get-Command aws -ErrorAction SilentlyContinue
if (-not $aws) {
    Write-Host "Đang tải AWS CLI..."
    $url = "https://awscli.amazonaws.com/AWSCLIV2.msi"
    $output = "$env:TEMP\AWSCLIV2.msi"
    Invoke-WebRequest -Uri $url -OutFile $output
    Start-Process msiexec.exe -Wait -ArgumentList "/i $output /quiet"
    Remove-Item $output
    Write-Host "AWS CLI đã cài đặt xong." -ForegroundColor Green
} else {
    Write-Host "AWS CLI đã có sẵn." -ForegroundColor Green
}

# --- 4. Kiểm tra kết quả ---
Write-Host "[4/4] Kiểm tra cài đặt..." -ForegroundColor Yellow
Write-Host ""
Write-Host "Terraform version:" -ForegroundColor Cyan
terraform version
Write-Host ""
Write-Host "AWS CLI version:" -ForegroundColor Cyan
aws --version
Write-Host ""

# --- Hướng dẫn tiếp theo ---
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  CÀI ĐẶT HOÀN TẤT!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Tiếp theo, hãy cấu hình AWS credentials:" -ForegroundColor Yellow
Write-Host "  aws configure" -ForegroundColor White
Write-Host ""
Write-Host "Sau đó vào thư mục configs và bắt đầu lab:" -ForegroundColor Yellow
Write-Host "  cd configs" -ForegroundColor White
Write-Host "  terraform init" -ForegroundColor White
