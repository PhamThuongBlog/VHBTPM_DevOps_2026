#!/bin/bash
# ============================================================
# verify.sh — Script kiểm tra kết quả Lab 5
# ============================================================
# Usage: bash verify.sh
# Chạy trong thư mục devops-lab5-student-manager

set -e

PASS=0
FAIL=0
TOTAL=0

check() {
    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] $1 ... "
    if [ "$2" = "OK" ]; then
        echo "✅ PASS"
        PASS=$((PASS + 1))
    else
        echo "❌ $2"
        FAIL=$((FAIL + 1))
    fi
}

echo "==============================================="
echo "  VERIFY — Lab 5 Git Flow & Code Review"
echo "==============================================="
echo ""

# --- 1. Git config ---
if git config user.name &>/dev/null; then
    check "Git user.name configured: $(git config user.name)" "OK"
else
    check "Git user.name configured" "Not configured. Run: git config --global user.name"
fi

if git config user.email &>/dev/null; then
    check "Git user.email configured: $(git config user.email)" "OK"
else
    check "Git user.email configured" "Not configured. Run: git config --global user.email"
fi

# --- 2. Is this a git repo? ---
if git rev-parse --git-dir &>/dev/null; then
    check "Current directory is a Git repository" "OK"
else
    check "Current directory is a Git repository" "Not a git repo. Run: git init"
fi

# --- 3. Has remote origin? ---
if git remote get-url origin &>/dev/null; then
    check "Remote origin: $(git remote get-url origin)" "OK"
else
    check "Remote origin configured" "Not configured. Run: git remote add origin <url>"
fi

# --- 4. Has commits? ---
COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
if [ "$COMMIT_COUNT" -ge 3 ]; then
    check "Has ≥3 commits ($COMMIT_COUNT total)" "OK"
else
    check "Has ≥3 commits" "Only $COMMIT_COUNT commits. Make more commits."
fi

# --- 5. Has develop branch? ---
if git branch --list develop | grep -q develop || git branch -a | grep -q develop; then
    check "Has 'develop' branch" "OK"
else
    check "Has 'develop' branch" "Missing. Run: git checkout -b develop"
fi

# --- 6. Has feature branches? ---
FEATURE_COUNT=$(git branch -a 2>/dev/null | grep -c "feature/" || echo "0")
if [ "$FEATURE_COUNT" -ge 1 ]; then
    check "Has ≥1 feature branch(es) ($FEATURE_COUNT found)" "OK"
else
    check "Has ≥1 feature branch(es)" "No feature/* branches found"
fi

# --- 7. Has .gitignore? ---
if [ -f ".gitignore" ]; then
    check ".gitignore exists" "OK"
else
    check ".gitignore exists" "Missing. Create a .gitignore file."
fi

# --- 8. Has README.md? ---
if [ -f "README.md" ]; then
    LINES=$(wc -l < README.md)
    if [ "$LINES" -ge 5 ]; then
        check "README.md exists (≥5 lines)" "OK"
    else
        check "README.md exists (≥5 lines)" "Only $LINES lines — add more content"
    fi
else
    check "README.md exists" "Missing. Create README.md"
fi

# --- 9. Has src/ directory? ---
if [ -d "src" ]; then
    check "src/ directory exists" "OK"
else
    check "src/ directory exists" "Missing src/ directory"
fi

# --- 10. Has Python files? ---
PY_FILES=$(find src -name "*.py" 2>/dev/null | wc -l || echo "0")
if [ "$PY_FILES" -ge 2 ]; then
    check "Has ≥2 Python files ($PY_FILES found)" "OK"
else
    check "Has ≥2 Python files" "Only $PY_FILES .py file(s) found"
fi

# --- 11. Python code runs? ---
if [ -f "src/main.py" ]; then
    if python3 src/main.py &>/dev/null || python src/main.py &>/dev/null; then
        check "src/main.py runs successfully" "OK"
    else
        check "src/main.py runs successfully" "Python error — check code"
    fi
else
    check "src/main.py runs successfully" "src/main.py not found"
fi

# --- Summary ---
echo ""
echo "==============================================="
echo "  RESULTS: $PASS/$TOTAL PASS, $FAIL FAIL"
echo "==============================================="

if [ "$FAIL" -eq 0 ]; then
    echo ""
    echo "🎉 All checks PASS! Git Flow lab completed successfully."
else
    echo ""
    echo "⚠️  $FAIL issue(s) found. Fix and re-run verify.sh"
fi
