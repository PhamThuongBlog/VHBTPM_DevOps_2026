#!/bin/bash
# ============================================================
# cleanup.sh — Script dọn dẹp Lab 6
# ============================================================
echo "==============================================="
echo "  CLEANUP — Lab 6 Testing Environment"
echo "==============================================="

# Stop SonarQube container
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "lab6-sonarqube"; then
    echo "Stopping SonarQube..."
    docker stop lab6-sonarqube && docker rm lab6-sonarqube
    echo "✅ SonarQube stopped and removed."
else
    echo "SonarQube not running."
fi

# Kill any running node server on port 3000
if lsof -i :3000 &>/dev/null 2>&1; then
    echo "Stopping Node server on port 3000..."
    kill $(lsof -t -i :3000) 2>/dev/null || true
    echo "✅ Server stopped."
fi

# Clean reports
echo "Cleaning report files..."
rm -f newman-report.json zap-report.html .scannerwork 2>/dev/null
rm -rf .scannerwork/ 2>/dev/null

echo ""
echo "==============================================="
echo "  CLEANUP COMPLETE!"
echo "==============================================="
