#!/bin/bash
# ============================================================
# capstone-cleanup.sh — Dọn dẹp Capstone
# ============================================================
echo "Cleaning up Capstone..."
docker stop capstone-jenkins capstone-nexus capstone-sonarqube student-manager 2>/dev/null
docker rm capstone-jenkins capstone-nexus capstone-sonarqube student-manager 2>/dev/null
docker volume rm capstone_jenkins_home capstone_nexus_data capstone_sonar_data 2>/dev/null
docker network rm capstone_devops-net 2>/dev/null
echo "✅ Capstone cleaned up."
