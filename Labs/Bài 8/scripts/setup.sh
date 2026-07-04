#!/bin/bash
# ============================================================
# setup.sh — Script cài đặt môi trường Lab 8
# ============================================================
set -e
echo "==============================================="
echo "  Lab 8 — Setup Docker + Jenkins CD Environment"
echo "==============================================="
echo ""

echo "[1/3] Checking Docker..."
if ! docker info &>/dev/null; then
    echo "ERROR: Docker not running! Start Docker Desktop."
    exit 1
fi
echo "Docker: $(docker --version)"

echo "[2/3] Checking Docker Compose..."
echo "Compose: $(docker compose version)"

echo "[3/3] Docker Hub Ready?"
echo "Make sure you have:"
echo "  ✅ Docker Hub account (hub.docker.com)"
echo "  ✅ docker login done"
echo ""
echo "==============================================="
echo "  SETUP COMPLETE!"
echo "==============================================="
echo "Next: Follow Lab8_HuongDan.md"
