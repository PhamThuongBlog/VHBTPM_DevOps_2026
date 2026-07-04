#!/bin/bash
# ============================================================
# verify.sh — Script kiểm tra kết quả Lab 1
# ============================================================
PASS=0; FAIL=0; TOTAL=0
check() {
    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] $1 ... "
    if [ "$2" = "OK" ]; then echo "✅ PASS"; PASS=$((PASS + 1))
    else echo "❌ $2"; FAIL=$((FAIL + 1)); fi
}

echo "==============================================="
echo "  VERIFY — Lab 1 DevOps Workflow"
echo "==============================================="
echo ""

# Git config
git config user.name &>/dev/null && check "Git user.name" "OK" || check "Git user.name" "Not configured"
git config user.email &>/dev/null && check "Git user.email" "OK" || check "Git user.email" "Not configured"

# Git repo
git rev-parse --git-dir &>/dev/null && check "Git repository" "OK" || check "Git repository" "Not a git repo"

# Remote
git remote get-url origin &>/dev/null && check "Remote origin: $(git remote get-url origin)" "OK" || check "Remote origin" "Not configured"

# index.html
[ -f "index.html" ] && check "index.html exists" "OK" || check "index.html exists" "File not found"
[ -f "index.html" ] && [ "$(wc -l < index.html)" -ge 10 ] && check "index.html ≥ 10 lines" "OK" || check "index.html ≥ 10 lines" "File too short"

# GitHub Actions workflow
[ -f ".github/workflows/deploy.yml" ] && check ".github/workflows/deploy.yml exists" "OK" || check ".github/workflows/deploy.yml exists" "Pipeline file not found"

# Has commits
COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")
[ "$COMMITS" -ge 1 ] && check "Has ≥ 1 commit" "OK" || check "Has ≥ 1 commit" "No commits yet"

echo ""
echo "==============================================="
echo "  RESULTS: $PASS/$TOTAL PASS, $FAIL FAIL"
echo "==============================================="
[ "$FAIL" -eq 0 ] && echo "🎉 All checks PASS! Ready to push to GitHub." || echo "⚠️  $FAIL issue(s) to fix"
echo ""
echo "After pushing to GitHub:"
echo "  1. Check Actions tab at your GitHub repo"
echo "  2. Check website at https://<USER>.github.io/<REPO>/"
