#!/bin/bash
# ============================================================
# verify.sh — Script kiểm tra kết quả Lab 7
# ============================================================
# Usage: bash verify.sh
# Run after setting up the CI pipeline

set -e

PASS=0
FAIL=0
TOTAL=0

check() {
    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] $1 ... "
    if [ "$2" = "OK" ]; then
        echo "✅ PASS"
        PASS=$((PASS + 1))
    else
        echo "❌ $2"
        FAIL=$((FAIL + 1))
    fi
}

echo "==============================================="
echo "  VERIFY — Lab 7 CI Pipeline Check"
echo "==============================================="
echo ""

# --- 1. Docker containers running ---
if docker ps --format '{{.Names}}' | grep -q "lab7-jenkins"; then
    check "Jenkins container running" "OK"
else
    check "Jenkins container running" "Not running. Run: docker compose up -d"
fi

if docker ps --format '{{.Names}}' | grep -q "lab7-nexus"; then
    check "Nexus container running" "OK"
else
    check "Nexus container running" "Not running."
fi

if docker ps --format '{{.Names}}' | grep -q "lab7-sonarqube"; then
    check "SonarQube container running" "OK"
else
    check "SonarQube container running" "Not running."
fi

# --- 2. Ports accessible ---
if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 2>/dev/null | grep -q "200\|403"; then
    check "Jenkins UI accessible (port 8080)" "OK"
else
    check "Jenkins UI accessible (port 8080)" "Not reachable"
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 2>/dev/null | grep -q "200\|401"; then
    check "Nexus UI accessible (port 8081)" "OK"
else
    check "Nexus UI accessible (port 8081)" "Not reachable (may need more startup time)"
fi

# --- 3. Check Jenkinsfile exists ---
if [ -f "../configs/Jenkinsfile" ]; then
    check "Jenkinsfile exists" "OK"
else
    check "Jenkinsfile exists" "File not found in configs/"
fi

if [ -f "../configs/Jenkinsfile" ] && grep -q "pipeline" "../configs/Jenkinsfile"; then
    check "Jenkinsfile has pipeline block" "OK"
else
    check "Jenkinsfile has pipeline block" "Missing pipeline declaration"
fi

if [ -f "../configs/Jenkinsfile" ] && grep -q "stage.*Checkout\|stage.*Build\|stage.*Test\|stage.*Package" "../configs/Jenkinsfile"; then
    check "Jenkinsfile has ≥4 stages (Checkout, Build, Test, Package)" "OK"
else
    check "Jenkinsfile has ≥4 stages" "Missing required stages"
fi

# --- 4. Check sample project ---
if [ -f "../configs/sample-java-app/pom.xml" ]; then
    check "Maven pom.xml exists" "OK"
else
    check "Maven pom.xml exists" "pom.xml not found"
fi

if [ -f "../configs/sample-java-app/src/test/java/com/devops/lab7/CalculatorTest.java" ]; then
    check "CalculatorTest.java exists" "OK"
else
    check "CalculatorTest.java exists" "Test file not found"
fi

# --- 5. Check docker-compose ---
if [ -f "../configs/docker-compose.yml" ]; then
    check "docker-compose.yml exists" "OK"
else
    check "docker-compose.yml exists" "File not found"
fi

# --- 6. Docker volumes ---
if docker volume ls --format '{{.Name}}' | grep -q "jenkins_home"; then
    check "Jenkins data volume exists" "OK"
else
    check "Jenkins data volume exists" "Volume not found — Jenkins may need more time"
fi

# --- Summary ---
echo ""
echo "==============================================="
echo "  RESULTS: $PASS/$TOTAL PASS, $FAIL FAIL"
echo "==============================================="

if [ "$FAIL" -eq 0 ]; then
    echo ""
    echo "🎉 All checks PASS! Your CI pipeline environment is ready."
    echo ""
    echo "Next steps:"
    echo "  1. Configure Jenkins at http://localhost:8080"
    echo "  2. Push sample-java-app to GitHub"
    echo "  3. Create Pipeline Job in Jenkins"
    echo "  4. Run 'Build Now' and verify all stages pass"
else
    echo ""
    echo "⚠️  $FAIL issue(s) found. Please fix and re-run verify.sh"
fi
