#!/bin/bash
# ============================================================
# cleanup.sh — Script dọn dẹp Lab 9
# ============================================================
echo "Cleaning up Lab 9..."

# Delete K8s resources
kubectl delete -f ../configs/student-frontend.yaml --ignore-not-found=true
kubectl delete -f ../configs/student-api.yaml --ignore-not-found=true
kubectl delete -f ../configs/deployment-nginx.yaml --ignore-not-found=true

# Stop Minikube
minikube stop

echo "✅ Lab 9 cleaned up. To fully remove: minikube delete"
