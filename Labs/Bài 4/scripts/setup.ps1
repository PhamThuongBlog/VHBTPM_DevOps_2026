# ============================================================
# setup.ps1 — Script cài đặt môi trường Lab 4 (Windows)
# ============================================================
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Lab 4 — Setup Ansible + Docker Environment" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "[1/4] Checking Ansible..." -ForegroundColor Yellow
$ansible = Get-Command ansible -ErrorAction SilentlyContinue
if (-not $ansible) { pip install ansible }
Write-Host "Ansible: $(ansible --version | Select-Object -First 1)" -ForegroundColor Green

Write-Host "[2/4] Checking Docker..." -ForegroundColor Yellow
docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR: Start Docker Desktop!" -ForegroundColor Red; exit 1 }
Write-Host "Docker: $(docker --version)" -ForegroundColor Green

Write-Host "[3/4] Creating managed nodes..." -ForegroundColor Yellow
docker network create ansible-lab 2>$null
docker run -d --name web-server-1 --network ansible-lab -p 2201:22 rastasheep/ubuntu-sshd:18.04
docker run -d --name web-server-2 --network ansible-lab -p 2202:22 rastasheep/ubuntu-sshd:18.04
docker run -d --name db-server-1 --network ansible-lab -p 2203:22 rastasheep/ubuntu-sshd:18.04
Write-Host "Containers created. Waiting 10s..." -ForegroundColor Yellow
Start-Sleep 10

Write-Host "[4/4] Testing Ansible..." -ForegroundColor Yellow
ansible all -m ping -i ../configs/inventory.ini

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
