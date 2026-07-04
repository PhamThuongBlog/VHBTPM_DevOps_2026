#!/bin/bash
# ============================================================
# verify.sh — Script kiểm tra kết quả Lab 9
# ============================================================
PASS=0; FAIL=0; TOTAL=0
check() {
    TOTAL=$((TOTAL + 1))
    echo -n "[$TOTAL] $1 ... "
    if [ "$2" = "OK" ]; then echo "✅ PASS"; PASS=$((PASS + 1))
    else echo "❌ $2"; FAIL=$((FAIL + 1)); fi
}

echo "==============================================="
echo "  VERIFY — Lab 9 Kubernetes & Microservices"
echo "==============================================="
echo ""

# Minikube/kubectl
command -v kubectl &>/dev/null && check "kubectl installed" "OK" || check "kubectl installed" "Not found"
kubectl cluster-info &>/dev/null && check "Cluster running" "OK" || check "Cluster running" "Run: minikube start"

# Deployments
kubectl get deploy nginx-deployment &>/dev/null && check "nginx-deployment exists" "OK" || check "nginx-deployment exists" "Not found"
kubectl get deploy student-api &>/dev/null && check "student-api deployment exists" "OK" || check "student-api deployment exists" "Not found"
kubectl get deploy student-frontend &>/dev/null && check "student-frontend deployment exists" "OK" || check "student-frontend deployment exists" "Not found"

# Pods running
NGINX_READY=$(kubectl get deploy nginx-deployment -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
[ "$NGINX_READY" -ge 1 ] && check "nginx pods ready ($NGINX_READY)" "OK" || check "nginx pods ready" "0 ready"

API_READY=$(kubectl get deploy student-api -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
[ "$API_READY" -ge 1 ] && check "student-api pods ready ($API_READY)" "OK" || check "student-api pods ready" "0 ready"

# Services
kubectl get svc api-svc &>/dev/null && check "api-svc exists" "OK" || check "api-svc exists" "Not found"
kubectl get svc frontend-svc &>/dev/null && check "frontend-svc exists" "OK" || check "frontend-svc exists" "Not found"

echo ""
echo "==============================================="
echo "  RESULTS: $PASS/$TOTAL PASS, $FAIL FAIL"
echo "==============================================="
