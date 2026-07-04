#!/bin/bash
# ============================================================
# capstone-setup.sh — Cài đặt toàn bộ môi trường Capstone
# ============================================================
set -e
echo "==============================================="
echo "  🏆 CAPSTONE — Setup DevOps Environment"
echo "==============================================="

echo "[1/4] Checking Docker..."
docker info &>/dev/null || { echo "Start Docker Desktop!"; exit 1; }

echo "[2/4] Starting Infrastructure (Jenkins+Nexus+SonarQube)..."
docker compose -f configs/docker-compose-infra.yml up -d
echo "Waiting 90s for services..."
sleep 90

echo "[3/4] Getting Initial Passwords..."
echo -n "Jenkins:  "; docker exec capstone-jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "(waiting...)"
echo -n "Nexus:    "; docker exec capstone-nexus cat /nexus-data/admin.password 2>/dev/null || echo "(waiting...)"
echo "SonarQube: admin / admin"

echo "[4/4] Configure Jenkins Tools..."
echo "Open http://localhost:8080 → Install suggested plugins → Create admin user"
echo "Manage Jenkins → Tools → Maven → Add Maven 'M3' (install automatically 3.9.x)"
echo "Manage Jenkins → Tools → JDK → Add JDK 'JDK17' (JAVA_HOME=/opt/java/openjdk)"

echo ""
echo "==============================================="
echo "  SETUP COMPLETE! Next:"
echo "==============================================="
echo "  1. Configure Jenkins at http://localhost:8080"
echo "  2. cd student-manager && mvn clean test"
echo "  3. Push code to GitHub"
echo "  4. Create Jenkins Pipeline job → Build Now!"
echo "  5. Follow CAPSTONE_GUIDE.md"
