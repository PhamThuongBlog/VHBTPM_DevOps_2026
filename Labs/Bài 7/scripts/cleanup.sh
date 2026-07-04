#!/bin/bash
# ============================================================
# cleanup.sh — Script dọn dẹp Lab 7
# ============================================================
# Usage: bash cleanup.sh
# Stops and removes Jenkins + Nexus + SonarQube containers

set -e

echo "==============================================="
echo "  CLEANUP — Lab 7 CI Pipeline Environment"
echo "==============================================="
echo ""

# --- Show running containers ---
echo "Running lab7 containers:"
docker ps --filter "name=lab7" --format "  {{.Names}} ({{.Status}})"
echo ""

# --- Confirm ---
echo "⚠️  This will stop and remove ALL lab7 containers."
echo "   Data volumes will be preserved (use -v flag to also remove volumes)."
echo ""
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled. Containers are still running."
    exit 0
fi

# --- Stop and remove ---
COMPOSE_FILE="$(cd "$(dirname "$0")" && pwd)/../configs/docker-compose.yml"

if [ "$1" = "-v" ] || [ "$1" = "--volumes" ]; then
    echo "Removing containers AND volumes..."
    docker compose -f "$COMPOSE_FILE" down -v
else
    echo "Removing containers (volumes preserved)..."
    docker compose -f "$COMPOSE_FILE" down
fi

echo ""
echo "==============================================="
echo "  CLEANUP COMPLETE!"
echo "==============================================="
echo ""

# Verify
REMAINING=$(docker ps -a --filter "name=lab7" --format "{{.Names}}" 2>/dev/null)
if [ -z "$REMAINING" ]; then
    echo "✅ No lab7 containers remaining."
else
    echo "⚠️  Some containers still exist: $REMAINING"
    echo "   Run 'docker rm -f $REMAINING' to force remove."
fi

echo ""
echo "To remove Docker volumes (frees ~3GB disk):"
echo "  bash cleanup.sh -v"
