#!/bin/bash
# ============================================================
# cleanup.sh — Script dọn dẹp Lab 2
# ============================================================
echo "==============================================="
echo "  CLEANUP — Lab 2"
echo "==============================================="
echo ""

# Stop Docker container if running
if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "lab2-app"; then
    echo "Stopping lab2-app container..."
    docker stop lab2-app && docker rm lab2-app
    echo "✅ Container removed."
else
    echo "No lab2-app container running."
fi

# Remove Docker image
if docker images --format '{{.Repository}}' 2>/dev/null | grep -q "devops-lab2-app"; then
    echo "Removing devops-lab2-app image..."
    docker rmi devops-lab2-app 2>/dev/null || true
    echo "✅ Image removed."
fi

echo ""
echo "==============================================="
echo "  CLEANUP COMPLETE!"
echo "==============================================="
