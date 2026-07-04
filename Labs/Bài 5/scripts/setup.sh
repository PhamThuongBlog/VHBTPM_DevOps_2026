#!/bin/bash
# ============================================================
# setup.sh — Script cài đặt môi trường Lab 5 (macOS/Linux)
# ============================================================
# Usage: bash setup.sh

set -e

echo "==============================================="
echo "  Lab 5 — Setup Git & GitHub Environment"
echo "==============================================="
echo ""

# --- 1. Check Git ---
echo "[1/3] Checking Git..."
if ! command -v git &> /dev/null; then
    echo "Git chưa được cài đặt."
    case "$(uname -s)" in
        Darwin) brew install git ;;
        Linux)  sudo apt update && sudo apt install -y git ;;
    esac
    echo "Git installed."
else
    echo "Git: $(git --version)"
fi

# --- 2. Configure Git ---
echo "[2/3] Configure Git..."
if [ -z "$(git config --global user.name)" ]; then
    read -p "Enter your full name: " name
    git config --global user.name "$name"
fi
echo "  user.name = $(git config --global user.name)"

if [ -z "$(git config --global user.email)" ]; then
    read -p "Enter your email: " email
    git config --global user.email "$email"
fi
echo "  user.email = $(git config --global user.email)"

git config --global init.defaultBranch main
git config --global core.editor "code --wait"
echo "  init.defaultBranch = main"
echo "  core.editor = code --wait"

# --- 3. Check GitHub ---
echo "[3/3] GitHub Ready?"
echo "Make sure you have:"
echo "  ✅ GitHub account (github.com)"
echo "  ✅ Personal Access Token (Settings → Developer settings → PAT)"

echo ""
echo "==============================================="
echo "  SETUP COMPLETE!"
echo "==============================================="
