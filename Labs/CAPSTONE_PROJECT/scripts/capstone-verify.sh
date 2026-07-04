#!/bin/bash
# ============================================================
# capstone-verify.sh — Kiểm tra toàn bộ Capstone pipeline
# ============================================================
PASS=0; FAIL=0; TOTAL=0
check() {
    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] $1 ... "
    if [ "$2" = "OK" ]; then echo "✅ PASS"; PASS=$((PASS + 1))
    else echo "❌ $2"; FAIL=$((FAIL + 1)); fi
}

echo "==============================================="
echo "  🏆 CAPSTONE VERIFICATION"
echo "==============================================="

# Infrastructure
for svc in capstone-jenkins capstone-nexus capstone-sonarqube; do
    docker ps --format '{{.Names}}' | grep -q "$svc" && check "$svc running" "OK" || check "$svc" "Not running"
done

# Code
[ -f "student-manager/pom.xml" ] && check "pom.xml exists" "OK" || check "pom.xml" "Not found"
[ -f "student-manager/Jenkinsfile" ] && check "Jenkinsfile exists" "OK" || check "Jenkinsfile" "Not found"
[ -f "Dockerfile" ] || [ -f "student-manager/Dockerfile" ] && check "Dockerfile exists" "OK" || check "Dockerfile" "Not found"

# Build
(cd student-manager && mvn clean compile -q &>/dev/null) && check "Maven build OK" "OK" || check "Maven build" "Compilation failed"

# Tests
(cd student-manager && mvn test -q &>/dev/null) && check "Maven tests OK" "OK" || check "Maven tests" "Tests failed"

# SonarQube
curl -s http://localhost:9000 &>/dev/null && check "SonarQube accessible" "OK" || check "SonarQube" "Not reachable"
curl -s http://localhost:8081 &>/dev/null && check "Nexus accessible" "OK" || check "Nexus" "Not reachable"
curl -s http://localhost:8080 &>/dev/null && check "Jenkins accessible" "OK" || check "Jenkins" "Not reachable"

# App (if deployed)
curl -s http://localhost:8080/api/students/health &>/dev/null && check "Student Manager App UP" "OK" || check "App" "Not running — deploy first"

echo ""
echo "==============================================="
echo "  RESULTS: $PASS/$TOTAL PASS, $FAIL FAIL"
echo "==============================================="
[ "$FAIL" -eq 0 ] && echo "🎉 CAPSTONE PIPELINE READY!" || echo "⚠️  $FAIL issues to fix"
