#!/bin/bash
# ============================================================
# cleanup.sh — Script dọn dẹp Lab 4
# ============================================================
echo "Cleaning up Lab 4..."
docker stop web-server-1 web-server-2 db-server-1 2>/dev/null
docker rm web-server-1 web-server-2 db-server-1 2>/dev/null
docker network rm ansible-lab 2>/dev/null
echo "✅ Lab 4 containers removed."
