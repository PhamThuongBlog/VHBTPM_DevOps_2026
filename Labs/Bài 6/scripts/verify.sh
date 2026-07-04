#!/bin/bash
# ============================================================
# verify.sh — Script kiểm tra kết quả Lab 6
# ============================================================
set -e

PASS=0; FAIL=0; TOTAL=0

check() {
    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] $1 ... "
    if [ "$2" = "OK" ]; then echo "✅ PASS"; PASS=$((PASS + 1))
    else echo "❌ $2"; FAIL=$((FAIL + 1)); fi
}

echo "==============================================="
echo "  VERIFY — Lab 6 Testing & Static Analysis"
echo "==============================================="
echo ""

# --- Tools ---
command -v node &>/dev/null && check "Node.js installed" "OK" || check "Node.js installed" "Not found"
command -v newman &>/dev/null && check "Newman CLI installed" "OK" || check "Newman CLI installed" "Run: npm install -g newman"
command -v docker &>/dev/null && check "Docker installed" "OK" || check "Docker installed" "Not found"

# --- Sample API ---
if [ -f "configs/sample-api/server.js" ]; then
    check "server.js exists" "OK"
else
    check "server.js exists" "File not found"
fi

# --- Postman Collection ---
if [ -f "configs/Student-API-Tests.json" ]; then
    REQ_COUNT=$(python3 -c "import json; d=json.load(open('configs/Student-API-Tests.json')); print(len(d['item']))" 2>/dev/null || echo "0")
    if [ "$REQ_COUNT" -ge 5 ]; then
        check "Postman collection has ≥5 requests ($REQ_COUNT)" "OK"
    else
        check "Postman collection has ≥5 requests" "Only $REQ_COUNT requests"
    fi
else
    check "Postman collection exists" "File not found"
fi

# --- SonarQube ---
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "lab6-sonarqube"; then
    check "SonarQube container running" "OK"
else
    check "SonarQube container running" "Not running. Run: docker run -d --name lab6-sonarqube -p 9000:9000 sonarqube:lts-community"
fi

# --- Sonar config ---
[ -f "configs/sonar-project.properties" ] && check "sonar-project.properties exists" "OK" || check "sonar-project.properties exists" "Not found"

# --- ZAP ---
curl -s http://localhost:8080 > /dev/null 2>&1 && check "ZAP running on port 8080" "OK" || check "ZAP running on port 8080" "Not running — start ZAP Desktop"

# --- Newman report ---
[ -f "newman-report.json" ] && check "Newman report exists" "OK" || check "Newman report exists" "Not found — run: newman run configs/Student-API-Tests.json --reporters json"

# --- ZAP report ---
[ -f "zap-report.html" ] && check "ZAP report exists" "OK" || check "ZAP report exists" "Not found — run ZAP scan first"

# --- CI Script ---
[ -f "configs/ci-test.sh" ] && check "ci-test.sh exists" "OK" || check "ci-test.sh exists" "Not found"

echo ""
echo "==============================================="
echo "  RESULTS: $PASS/$TOTAL PASS, $FAIL FAIL"
echo "==============================================="
[ "$FAIL" -eq 0 ] && echo "🎉 All checks PASS!" || echo "⚠️  $FAIL issue(s) to fix"
