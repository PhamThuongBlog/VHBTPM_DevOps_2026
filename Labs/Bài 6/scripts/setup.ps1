# ============================================================
# setup.ps1 — Script cài đặt môi trường Lab 6 (Windows)
# ============================================================
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "  Lab 6 — Setup Testing Environment" -ForegroundColor Cyan
Write-Host "  Postman + Newman + ZAP + SonarQube" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

# --- 1. Check Node.js ---
Write-Host "[1/5] Checking Node.js..." -ForegroundColor Yellow
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Host "Node.js not found. Download from: https://nodejs.org/" -ForegroundColor Red
    exit 1
}
Write-Host "Node: $(node --version)" -ForegroundColor Green

# --- 2. Install Newman ---
Write-Host "[2/5] Installing Newman CLI..." -ForegroundColor Yellow
$newman = Get-Command newman -ErrorAction SilentlyContinue
if (-not $newman) {
    npm install -g newman
    Write-Host "Newman installed." -ForegroundColor Green
} else {
    Write-Host "Newman: $(newman --version)" -ForegroundColor Green
}

# --- 3. Install Sonar Scanner ---
Write-Host "[3/5] Installing SonarScanner..." -ForegroundColor Yellow
$sonar = Get-Command sonar-scanner -ErrorAction SilentlyContinue
if (-not $sonar) {
    npm install -g sonarqube-scanner
    Write-Host "SonarScanner installed." -ForegroundColor Green
} else {
    Write-Host "SonarScanner already installed." -ForegroundColor Green
}

# --- 4. Check Docker ---
Write-Host "[4/5] Checking Docker..." -ForegroundColor Yellow
$docker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $docker) {
    Write-Host "Docker not found. Download from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
} else {
    Write-Host "Docker: $(docker --version)" -ForegroundColor Green
}

# --- 5. Check ZAP ---
Write-Host "[5/5] Checking OWASP ZAP..." -ForegroundColor Yellow
$zapPaths = @(
    "${env:ProgramFiles}\OWASP\Zed Attack Proxy\zap.exe",
    "${env:ProgramFiles(x86)}\OWASP\Zed Attack Proxy\zap.exe"
)
$found = $false
foreach ($p in $zapPaths) {
    if (Test-Path $p) { Write-Host "ZAP found: $p" -ForegroundColor Green; $found = $true; break }
}
if (-not $found) {
    Write-Host "ZAP not found. Download from: https://www.zaproxy.org/download/" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "===============================================" -ForegroundColor Green
Write-Host "  SETUP HOÀN TẤT!" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. cd configs/sample-api && npm install && node server.js" -ForegroundColor White
Write-Host "  2. Open Postman → Import Student-API-Tests.json" -ForegroundColor White
Write-Host "  3. Start ZAP Desktop" -ForegroundColor White
Write-Host "  4. docker run -d --name lab6-sonarqube -p 9000:9000 sonarqube:lts-community" -ForegroundColor White
