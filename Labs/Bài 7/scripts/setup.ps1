# ============================================================
# setup.ps1 — Script cài đặt môi trường Lab 7 (Windows)
# ============================================================
# Chạy bằng PowerShell
# Usage: .\setup.ps1

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Lab 7 - Setup CI Pipeline Environment" -ForegroundColor Cyan
Write-Host "  Jenkins + Nexus + SonarQube via Docker" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. Check Docker ---
Write-Host "[1/5] Checking Docker..." -ForegroundColor Yellow
$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    Write-Host "ERROR: Docker is not installed!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
    exit 1
}
Write-Host "Docker found: $(docker --version)" -ForegroundColor Green

# Check Docker is running
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Docker is not running! Start Docker Desktop first." -ForegroundColor Red
    exit 1
}
Write-Host "Docker is running." -ForegroundColor Green

# --- 2. Check Git ---
Write-Host "[2/5] Checking Git..." -ForegroundColor Yellow
$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) {
    Write-Host "ERROR: Git is not installed!" -ForegroundColor Red
    Write-Host "Download from: https://git-scm.com/downloads" -ForegroundColor Red
    exit 1
}
Write-Host "Git found: $(git --version)" -ForegroundColor Green

# --- 3. Check Java ---
Write-Host "[3/5] Checking Java..." -ForegroundColor Yellow
$java = Get-Command java -ErrorAction SilentlyContinue
if (-not $java) {
    Write-Host "WARNING: Java not found in PATH. The Maven wrapper will handle this." -ForegroundColor Yellow
    Write-Host "If you need it, download from: https://adoptium.net/" -ForegroundColor Yellow
} else {
    Write-Host "Java found: $(java --version 2>&1 | Select-Object -First 1)" -ForegroundColor Green
}

# --- 4. Check Ports ---
Write-Host "[4/5] Checking port availability..." -ForegroundColor Yellow
$ports = @(8080, 8081, 9000)
foreach ($port in $ports) {
    $inUse = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($inUse) {
        Write-Host "WARNING: Port $port is in use! You may need to change the port in docker-compose.yml" -ForegroundColor Yellow
    } else {
        Write-Host "Port $port is available." -ForegroundColor Green
    }
}

# --- 5. Start Docker Stack ---
Write-Host "[5/5] Starting Jenkins + Nexus + SonarQube..." -ForegroundColor Yellow
Write-Host "This will download ~2GB of Docker images (first time only)..."
Write-Host ""

$configPath = Join-Path $PSScriptRoot "..\configs"
if (Test-Path "$configPath\docker-compose.yml") {
    docker compose -f "$configPath\docker-compose.yml" up -d
} else {
    Write-Host "ERROR: docker-compose.yml not found in configs/" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Waiting for services to start (60 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Show initial passwords
Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  SETUP HOÀN TẤT!"
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Services:" -ForegroundColor Cyan
Write-Host "  Jenkins:    http://localhost:8080" -ForegroundColor White
Write-Host "  Nexus:      http://localhost:8081" -ForegroundColor White
Write-Host "  SonarQube:  http://localhost:9000" -ForegroundColor White
Write-Host ""

Write-Host "Initial Passwords:" -ForegroundColor Cyan
$jenkinsPass = docker exec lab7-jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>$null
if ($jenkinsPass) { Write-Host "  Jenkins:   $jenkinsPass" -ForegroundColor White }
$nexusPass = docker exec lab7-nexus cat /nexus-data/admin.password 2>$null
if ($nexusPass) { Write-Host "  Nexus:     $nexusPass" -ForegroundColor White }
Write-Host "  SonarQube: admin / admin" -ForegroundColor White
