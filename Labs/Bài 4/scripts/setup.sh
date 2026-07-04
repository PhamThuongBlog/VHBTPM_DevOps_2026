#!/bin/bash
# ============================================================
# setup.sh — Script cài đặt môi trường Lab 4
# ============================================================
set -e
echo "==============================================="
echo "  Lab 4 — Setup Ansible + Docker Environment"
echo "==============================================="
echo ""

# Check Ansible
echo "[1/4] Checking Ansible..."
if ! command -v ansible &>/dev/null; then
    echo "Installing Ansible..."
    pip install ansible
fi
echo "Ansible: $(ansible --version | head -1)"

# Check Docker
echo "[2/4] Checking Docker..."
if ! docker info &>/dev/null; then
    echo "ERROR: Docker not running! Start Docker Desktop."
    exit 1
fi
echo "Docker: $(docker --version)"

# Setup managed nodes
echo "[3/4] Creating managed nodes..."
docker network create ansible-lab 2>/dev/null || true
docker run -d --name web-server-1 --network ansible-lab -p 2201:22 rastasheep/ubuntu-sshd:18.04
docker run -d --name web-server-2 --network ansible-lab -p 2202:22 rastasheep/ubuntu-sshd:18.04
docker run -d --name db-server-1 --network ansible-lab -p 2203:22 rastasheep/ubuntu-sshd:18.04

echo "Waiting for containers..."
sleep 10

# Test
echo "[4/4] Testing Ansible connection..."
ansible all -m ping -i ../configs/inventory.ini

echo ""
echo "==============================================="
echo "  SETUP COMPLETE! 3 servers ready."
echo "==============================================="
