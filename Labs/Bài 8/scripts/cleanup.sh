#!/bin/bash
# ============================================================
# cleanup.sh — Script dọn dẹp Lab 8
# ============================================================
echo "Cleaning up Lab 8..."

# Stop Docker Compose
docker compose -f ../configs/docker-compose.yml down 2>/dev/null || true

# Stop individual containers
for c in lab8-app lab8-cd-production lab8-nginx lab8-redis lab8-test-pull; do
    docker stop $c 2>/dev/null && docker rm $c 2>/dev/null || true
done

# Remove images (optional)
# docker rmi devops-lab8-app:1.0 devops-lab8-app:latest 2>/dev/null || true

echo "✅ Lab 8 cleaned up."
