# ============================================================
# setup.ps1 — Script cài đặt Minikube + kubectl (Windows)
# ============================================================
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Lab 9 — Setup Kubernetes Environment" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan

Write-Host "[1/3] Checking Docker..." -ForegroundColor Yellow
docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) { Write-Host "ERROR: Start Docker Desktop!" -ForegroundColor Red; exit 1 }
Write-Host "Docker: $(docker --version)" -ForegroundColor Green

Write-Host "[2/3] Checking kubectl..." -ForegroundColor Yellow
$kubectl = Get-Command kubectl -ErrorAction SilentlyContinue
if (-not $kubectl) { Write-Host "kubectl not found. Install from: https://kubernetes.io/docs/tasks/tools/" -ForegroundColor Red }
else { Write-Host "kubectl: $(kubectl version --client --short 2>$null)" -ForegroundColor Green }

Write-Host "[3/3] Starting Minikube..." -ForegroundColor Yellow
$minikube = Get-Command minikube -ErrorAction SilentlyContinue
if (-not $minikube) { choco install minikube -y }
minikube start --driver=docker --memory=4096 --cpus=2

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
