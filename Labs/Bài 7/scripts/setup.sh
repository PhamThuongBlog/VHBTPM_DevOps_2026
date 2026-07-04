#!/bin/bash
# ============================================================
# setup.sh — Script cài đặt môi trường Lab 7 (macOS/Linux)
# ============================================================
# Usage: bash setup.sh

set -e

echo "==============================================="
echo "  Lab 7 - Setup CI Pipeline Environment"
echo "  Jenkins + Nexus + SonarQube via Docker"
echo "==============================================="
echo ""

# --- 1. Check Docker ---
echo "[1/5] Checking Docker..."
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed!"
    echo "Install: https://docs.docker.com/engine/install/"
    exit 1
fi
echo "Docker: $(docker --version)"

if ! docker info &> /dev/null; then
    echo "ERROR: Docker daemon is not running!"
    exit 1
fi
echo "Docker daemon is running."

# --- 2. Check Git ---
echo "[2/5] Checking Git..."
if ! command -v git &> /dev/null; then
    echo "ERROR: Git is not installed!"
    exit 1
fi
echo "Git: $(git --version)"

# --- 3. Check Java ---
echo "[3/5] Checking Java..."
if command -v java &> /dev/null; then
    echo "Java: $(java --version 2>&1 | head -1)"
else
    echo "WARNING: Java not found. Maven wrapper will handle this."
fi

# --- 4. Check Ports ---
echo "[4/5] Checking port availability..."
for port in 8080 8081 9000; do
    if lsof -i :$port &> /dev/null 2>&1 || ss -tlnp | grep -q ":$port " 2>/dev/null; then
        echo "WARNING: Port $port is in use!"
    else
        echo "Port $port is available."
    fi
done

# --- 5. Start Docker Stack ---
echo "[5/5] Starting Jenkins + Nexus + SonarQube..."
echo "Downloading ~2GB Docker images (first time only)..."

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/../configs/docker-compose.yml"

if [ -f "$COMPOSE_FILE" ]; then
    docker compose -f "$COMPOSE_FILE" up -d
else
    echo "ERROR: docker-compose.yml not found!"
    exit 1
fi

echo ""
echo "Waiting for services to start (60 seconds)..."
sleep 60

# Show initial passwords
echo ""
echo "==============================================="
echo "  SETUP COMPLETE!"
echo "==============================================="
echo ""
echo "Services:"
echo "  Jenkins:    http://localhost:8080"
echo "  Nexus:      http://localhost:8081"
echo "  SonarQube:  http://localhost:9000"
echo ""
echo "Initial Passwords:"
echo -n "  Jenkins:   "
docker exec lab7-jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "(may need more time)"
echo -n "  Nexus:     "
docker exec lab7-nexus cat /nexus-data/admin.password 2>/dev/null || echo "(may need more time)"
echo "  SonarQube: admin / admin"
