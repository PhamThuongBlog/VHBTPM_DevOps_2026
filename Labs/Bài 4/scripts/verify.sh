#!/bin/bash
# ============================================================
# verify.sh — Script kiểm tra kết quả Lab 4
# ============================================================
PASS=0; FAIL=0; TOTAL=0
check() {
    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] $1 ... "
    if [ "$2" = "OK" ]; then echo "✅ PASS"; PASS=$((PASS + 1))
    else echo "❌ $2"; FAIL=$((FAIL + 1)); fi
}

echo "==============================================="
echo "  VERIFY — Lab 4 Ansible"
echo "==============================================="
echo ""

# Ansible
command -v ansible &>/dev/null && check "Ansible installed" "OK" || check "Ansible installed" "Not found"

# Docker
docker info &>/dev/null && check "Docker running" "OK" || check "Docker running" "Start Docker Desktop"

# Containers
for c in web-server-1 web-server-2 db-server-1; do
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q "$c" && check "Container $c running" "OK" || check "Container $c running" "Not found"
done

# Ping
ansible all -m ping -i ../configs/inventory.ini &>/dev/null && check "Ansible ping all hosts" "OK" || check "Ansible ping all hosts" "Connection failed"

# Playbook files
[ -f "../configs/playbook-webserver.yml" ] && check "playbook-webserver.yml exists" "OK" || check "playbook-webserver.yml" "Not found"
[ -f "../configs/playbook-full.yml" ] && check "playbook-full.yml exists" "OK" || check "playbook-full.yml" "Not found"
[ -f "../configs/inventory.ini" ] && check "inventory.ini exists" "OK" || check "inventory.ini" "Not found"

echo ""
echo "==============================================="
echo "  RESULTS: $PASS/$TOTAL PASS, $FAIL FAIL"
echo "==============================================="
