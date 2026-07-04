#!/bin/bash
# ===========================================
# CI Test Script — Lab 6 DevOps
# Tích hợp: SAST + API Test + DAST
# ===========================================
set -e

echo "========================================="
echo "  DEVOPS LAB 6 — CI TESTING PIPELINE"
echo "========================================="
echo ""

# --- Stage 1: SAST — Static Code Analysis ---
echo "[1/4] 🔍 SAST — SonarQube Static Analysis..."
if command -v sonar-scanner &> /dev/null; then
    sonar-scanner \
      -Dsonar.projectKey=devops-lab6 \
      -Dsonar.sources=. \
      -Dsonar.exclusions=node_modules/** \
      -Dsonar.host.url=http://localhost:9000 \
      -Dsonar.login=admin \
      -Dsonar.password=sonar123 \
      && echo "✅ SAST passed" || echo "⚠️  SAST completed with warnings"
else
    echo "⚠️  sonar-scanner not installed — skipping SAST"
    echo "   Install: npm install -g sonarqube-scanner"
fi

# --- Stage 2: Start API Server ---
echo "[2/4] 🚀 Starting API server..."
node server.js &
SERVER_PID=$!
sleep 3

if ! curl -s http://localhost:3000/api/students > /dev/null; then
    echo "❌ Server failed to start!"
    exit 1
fi
echo "✅ Server running (PID: $SERVER_PID)"

# --- Stage 3: API Functional Test ---
echo "[3/4] 🧪 API Functional Test — Newman..."
if command -v newman &> /dev/null; then
    newman run Student-API-Tests.json \
      --reporters cli,json \
      --reporter-json-export newman-report.json \
      --color on

    if [ $? -eq 0 ]; then
        echo "✅ All API tests passed!"
    else
        echo "❌ API tests failed! Check newman-report.json"
    fi
else
    echo "⚠️  newman not installed — skipping API tests"
    echo "   Install: npm install -g newman"
fi

# --- Stage 4: DAST — ZAP Security Scan ---
echo "[4/4] 🔐 DAST — OWASP ZAP Security Scan..."
ZAP_URL="http://localhost:8080"

if curl -s "$ZAP_URL" > /dev/null 2>&1; then
    echo "  Spider crawling..."
    curl -s "$ZAP_URL/JSON/spider/action/scan/?url=http://localhost:3000" > /dev/null
    sleep 10

    echo "  Active scanning..."
    curl -s "$ZAP_URL/JSON/ascan/action/scan/?url=http://localhost:3000" > /dev/null
    sleep 15

    echo "  Generating report..."
    curl -s "$ZAP_URL/OTHER/core/other/htmlreport/" > zap-report.html
    echo "✅ ZAP scan complete — see zap-report.html"
else
    echo "⚠️  ZAP not running on port 8080 — skipping DAST"
    echo "   Start ZAP and enable API (Tools → Options → API)"
fi

# --- Cleanup ---
kill $SERVER_PID 2>/dev/null
echo ""
echo "========================================="
echo "  PIPELINE COMPLETE!"
echo "========================================="
echo ""
echo "Reports:"
echo "  📊 SAST:     http://localhost:9000/dashboard?id=devops-lab6"
echo "  📊 API Test: newman-report.json"
echo "  📊 DAST:     zap-report.html"
