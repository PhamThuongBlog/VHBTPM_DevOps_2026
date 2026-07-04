# =============================================
# DevOps Lab 2 — Automation Setup Script (Windows)
# =============================================
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  🚀 DevOps Lab 2 — Auto Environment Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "[1/4] Checking prerequisites..." -ForegroundColor Yellow
$git = Get-Command git -ErrorAction SilentlyContinue
if ($git) { Write-Host "  ✅ Git: $(git --version)" -ForegroundColor Green }
else { Write-Host "  ❌ Git not found — install from https://git-scm.com/" -ForegroundColor Red }

$node = Get-Command node -ErrorAction SilentlyContinue
if ($node) { Write-Host "  ✅ Node.js: $(node --version)" -ForegroundColor Green }
else { Write-Host "  ⚠️  Node.js not found (optional)" -ForegroundColor Yellow }

Write-Host "[2/4] Creating project structure..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path src,tests,docs | Out-Null
Write-Host "  ✅ Created: src/ tests/ docs/" -ForegroundColor Green

Write-Host "[3/4] Initializing Git..." -ForegroundColor Yellow
if (-not (Test-Path ".git")) {
    git init
    Write-Host "  ✅ Git initialized" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Git already initialized" -ForegroundColor Yellow
}

Write-Host "[4/4] Generating config files..." -ForegroundColor Yellow
@"
node_modules/
.env
*.log
.DS_Store
dist/
.vscode/
"@ | Out-File -FilePath .gitignore -Encoding UTF8
Write-Host "  ✅ .gitignore created" -ForegroundColor Green

Write-Host ""
Write-Host "✅ SETUP COMPLETE!" -ForegroundColor Green
Write-Host "Project is ready at: $(Get-Location)" -ForegroundColor White
