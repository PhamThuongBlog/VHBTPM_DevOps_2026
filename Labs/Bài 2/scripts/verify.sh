#!/bin/bash
# ============================================================
# verify.sh — Script kiểm tra kết quả Lab 2
# ============================================================
PASS=0; FAIL=0; TOTAL=0
check() {
    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] $1 ... "
    if [ "$2" = "OK" ]; then echo "✅ PASS"; PASS=$((PASS + 1))
    else echo "❌ $2"; FAIL=$((FAIL + 1)); fi
}

echo "==============================================="
echo "  VERIFY — Lab 2 DevOps Principles & Toolchain"
echo "==============================================="
echo ""

# Toolchain
command -v git &>/dev/null && check "Git installed" "OK" || check "Git installed" "Not found"
command -v docker &>/dev/null && check "Docker installed" "OK" || check "Docker installed" "Not found"
code --version &>/dev/null && check "VS Code installed" "OK" || check "VS Code installed" "Not found"

# Automation script
[ -f "configs/setup-dev-env.sh" ] || [ -f "configs/setup-dev-env.ps1" ] && check "Automation script exists" "OK" || check "Automation script exists" "Not found"

# Docker config
[ -f "configs/Dockerfile" ] && check "Dockerfile exists" "OK" || check "Dockerfile exists" "Not found"
[ -f "configs/server.js" ] && check "server.js exists" "OK" || check "server.js exists" "Not found"
[ -f "configs/package.json" ] && check "package.json exists" "OK" || check "package.json exists" "Not found"

# Docker running
docker info &>/dev/null && check "Docker daemon running" "OK" || check "Docker daemon running" "Start Docker Desktop"

echo ""
echo "==============================================="
echo "  RESULTS: $PASS/$TOTAL PASS, $FAIL FAIL"
echo "==============================================="
[ "$FAIL" -eq 0 ] && echo "🎉 All checks PASS!" || echo "⚠️  $FAIL issue(s) to fix"
