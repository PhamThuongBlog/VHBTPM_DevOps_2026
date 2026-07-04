#!/bin/bash
# ============================================================
# setup.sh — Script cài đặt môi trường Lab 2
# ============================================================
echo "==============================================="
echo "  Lab 2 — Setup DevOps Environment"
echo "==============================================="
echo ""

echo "[1/3] Checking Git..."
command -v git &>/dev/null && echo "Git: $(git --version)" || echo "Git not found. Install: https://git-scm.com/"

echo "[2/3] Checking Docker..."
command -v docker &>/dev/null && echo "Docker: $(docker --version)" || echo "Docker not found. Install: https://www.docker.com/products/docker-desktop/"

echo "[3/3] Checking VS Code..."
code --version &>/dev/null && echo "VS Code found." || echo "VS Code not found. Install: https://code.visualstudio.com/"

echo ""
echo "==============================================="
echo "  SETUP COMPLETE!"
echo "==============================================="
echo "Next: Follow Lab2_HuongDan.md"
