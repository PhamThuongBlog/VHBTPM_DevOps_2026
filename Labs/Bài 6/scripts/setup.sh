#!/bin/bash
# ============================================================
# setup.sh — Script cài đặt môi trường Lab 6 (macOS/Linux)
# ============================================================
set -e

echo "==============================================="
echo "  Lab 6 — Setup Testing Environment"
echo "  Postman + Newman + ZAP + SonarQube"
echo "==============================================="
echo ""

# --- 1. Node.js ---
echo "[1/5] Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Install from: https://nodejs.org/"
    exit 1
fi
echo "Node: $(node --version)"

# --- 2. Newman ---
echo "[2/5] Installing Newman CLI..."
if ! command -v newman &> /dev/null; then
    npm install -g newman
fi
echo "Newman: $(newman --version)"

# --- 3. SonarScanner ---
echo "[3/5] Installing SonarScanner..."
if ! command -v sonar-scanner &> /dev/null; then
    npm install -g sonarqube-scanner
fi
echo "SonarScanner ready."

# --- 4. Docker ---
echo "[4/5] Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Install from: https://docs.docker.com/engine/install/"
else
    echo "Docker: $(docker --version)"
fi

# --- 5. ZAP ---
echo "[5/5] Checking OWASP ZAP..."
if command -v zap.sh &> /dev/null || [ -d "/Applications/OWASP ZAP.app" ]; then
    echo "ZAP found."
else
    echo "ZAP not found. Download from: https://www.zaproxy.org/download/"
fi

echo ""
echo "==============================================="
echo "  SETUP COMPLETE!"
echo "==============================================="
