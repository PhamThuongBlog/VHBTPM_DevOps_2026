#!/bin/bash
# ============================================================
# setup.sh — Script cài đặt Minikube + kubectl (macOS/Linux)
# ============================================================
set -e
echo "==============================================="
echo "  Lab 9 — Setup Kubernetes Environment"
echo "==============================================="
echo ""

echo "[1/3] Checking Docker..."
if ! docker info &>/dev/null; then
    echo "ERROR: Docker not running! Start Docker Desktop."
    exit 1
fi
echo "Docker: $(docker --version)"

echo "[2/3] Checking kubectl..."
if ! command -v kubectl &>/dev/null; then
    echo "Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
fi
echo "kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"

echo "[3/3] Starting Minikube..."
if ! command -v minikube &>/dev/null; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
fi

minikube start --driver=docker --memory=4096 --cpus=2

echo ""
echo "==============================================="
echo "  SETUP COMPLETE!"
echo "==============================================="
kubectl cluster-info
