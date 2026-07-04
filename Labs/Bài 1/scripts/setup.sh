#!/bin/bash
# ============================================================
# setup.sh — Script cài đặt môi trường Lab 1
# ============================================================
echo "==============================================="
echo "  Lab 1 — Setup DevOps Environment"
echo "==============================================="
echo ""

# Check Git
echo "[1/2] Checking Git..."
if ! command -v git &> /dev/null; then
    echo "Git not found. Install from: https://git-scm.com/downloads"
    exit 1
fi
echo "Git: $(git --version)"

# Check GitHub
echo "[2/2] GitHub Ready?"
echo "Make sure you have:"
echo "  ✅ GitHub account (github.com)"
echo "  ✅ Git configured (git config --global user.name/email)"
echo ""
echo "==============================================="
echo "  SETUP COMPLETE!"
echo "==============================================="
echo ""
echo "Next:"
echo "  1. Create repo on GitHub: devops-lab1-portfolio"
echo "  2. git clone https://github.com/<USER>/devops-lab1-portfolio.git"
echo "  3. Copy index.html to the repo folder"
echo "  4. Copy deploy.yml to .github/workflows/"
echo "  5. git add . && git commit && git push"
echo "  6. Watch Actions tab → Website goes live! 🚀"
