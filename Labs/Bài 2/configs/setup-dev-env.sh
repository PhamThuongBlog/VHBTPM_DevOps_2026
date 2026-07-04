#!/bin/bash
# =============================================
# DevOps Lab 2 — Automation Setup Script
# Tự động cài đặt môi trường development
# =============================================
set -e

echo "========================================="
echo "  🚀 DevOps Lab 2 — Auto Environment Setup"
echo "========================================="
echo ""

# --- Step 1: Check prerequisites ---
echo "[1/4] Checking prerequisites..."
command -v git &>/dev/null && echo "  ✅ Git: $(git --version)" || echo "  ❌ Git not found"
command -v node &>/dev/null && echo "  ✅ Node.js: $(node --version)" || echo "  ⚠️  Node.js not found (optional)"

# --- Step 2: Create project structure ---
echo "[2/4] Creating project structure..."
mkdir -p src tests docs
echo "  ✅ Created: src/ tests/ docs/"

# --- Step 3: Initialize Git ---
echo "[3/4] Initializing Git repository..."
if [ ! -d ".git" ]; then
    git init
    echo "  ✅ Git initialized"
else
    echo "  ⚠️  Git already initialized"
fi

# --- Step 4: Generate config files ---
echo "[4/4] Generating config files..."

cat > .gitignore << 'EOF'
node_modules/
.env
*.log
.DS_Store
dist/
.vscode/
EOF
echo "  ✅ .gitignore created"

cat > README.md << 'EOF'
# DevOps Lab 2 — Automation Demo

Môi trường được thiết lập tự động bởi `setup-dev-env.sh`

## Quick Start
```bash
bash setup-dev-env.sh    # Tự động cài đặt mọi thứ
```
EOF
echo "  ✅ README.md created"

echo ""
echo "========================================="
echo "  ✅ SETUP COMPLETE! (Time: ${SECONDS}s)"
echo "========================================="
echo ""
echo "Project is ready at: $(pwd)"
