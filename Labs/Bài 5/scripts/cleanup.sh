#!/bin/bash
# ============================================================
# cleanup.sh — Script dọn dẹp Lab 5
# ============================================================
# Usage: bash cleanup.sh
# Xóa branches local đã merge + hướng dẫn xóa repo GitHub

set -e

echo "==============================================="
echo "  CLEANUP — Lab 5 Git Flow"
echo "==============================================="
echo ""

REPO_DIR="devops-lab5-student-manager"

# --- Clean local branches ---
if [ -d "$REPO_DIR" ]; then
    cd "$REPO_DIR"

    echo "Current branches:"
    git branch -a
    echo ""

    echo "Cleaning merged local branches..."
    git checkout main 2>/dev/null || git checkout master 2>/dev/null || true

    # Delete local branches that have been merged
    for branch in $(git branch --merged | grep -v "main\|master\|develop" | sed 's/^\* //'); do
        git branch -d "$branch" 2>/dev/null && echo "  Deleted: $branch" || echo "  Skipped: $branch (has unmerged changes)"
    done

    echo ""
    echo "Remaining branches:"
    git branch
else
    echo "Repository directory '$REPO_DIR' not found."
fi

echo ""
echo "==============================================="
echo "  LOCAL CLEANUP DONE"
echo "==============================================="
echo ""
echo "To delete the GitHub repository:"
echo "  1. Go to: https://github.com/<USER>/devops-lab5-student-manager"
echo "  2. Settings → Danger Zone → Delete this repository"
echo ""
echo "To remove local files:"
echo "  cd .. && rm -rf $REPO_DIR"
