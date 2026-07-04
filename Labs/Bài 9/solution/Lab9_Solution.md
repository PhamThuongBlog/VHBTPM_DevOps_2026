# Lab 9 — Đáp án (Dành cho Giảng viên)

> **KHÔNG chia sẻ file này cho sinh viên!**

---

## Tổng quan

Lab cuối cùng — kết hợp **Kubernetes** (kỹ năng mới) + **Ôn tập tổng hợp** (9 bài). Dùng Minikube local thay vì cloud cluster (EKS/GKE) để giảm chi phí.

---

## Kết quả Mong đợi

### kubectl get all
```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/nginx-deployment-xxxxx-abcde        1/1     Running   0          10m
pod/nginx-deployment-xxxxx-fghij        1/1     Running   0          10m
pod/nginx-deployment-xxxxx-klmno        1/1     Running   0          10m
pod/student-api-xxxxx-abcde             1/1     Running   0          5m
pod/student-api-xxxxx-fghij             1/1     Running   0          5m
pod/student-frontend-xxxxx-abcde        1/1     Running   0          5m
pod/student-frontend-xxxxx-fghij        1/1     Running   0          5m

NAME                    TYPE        CLUSTER-IP      PORT(S)        AGE
service/kubernetes      ClusterIP   10.96.0.1       443/TCP        30m
service/api-svc         ClusterIP   10.96.xxx.xxx   3000/TCP       5m
service/frontend-svc    NodePort    10.96.xxx.xxx   80:30081/TCP   5m
service/nginx-service-np NodePort   10.96.xxx.xxx   80:30080/TCP   10m

NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-deployment     3/3     3            3           10m
deployment.apps/student-api          2/2     2            2           5m
deployment.apps/student-frontend     2/2     2            2           5m
```

### Microservices Demo
- Browser mở `http://localhost:30081` (hoặc `minikube service frontend-svc`)
- Hiển thị bảng 3 sinh viên với status "✅ Connected to API"
- Chứng minh: Frontend → api-svc:3000 (K8s Service Discovery)

### Self-healing
- `kubectl delete pod <api-pod>` → pod mới tự tạo lại
- `kubectl get pods -w` cho thấy quá trình

### Scale + Rollback
- `kubectl scale deploy student-api --replicas=5` → 5 pods
- `kubectl rollout undo deploy student-api` → rollback OK

---

## Đáp án Ôn tập Tổng hợp

### Bảng 9 Bài

| Bài | Công cụ | Lab |
|:---:|---------|:---:|
| 1 | GitHub Actions, Pages | CI/CD web |
| 2 | VS Code, Git, Docker | CALMS + Automation |
| 3 | Terraform, AWS | Provision EC2+S3 |
| 4 | Ansible, Docker | Config web servers |
| 5 | Git, GitHub | Git Flow + PR |
| 6 | Postman, ZAP, SonarQube | SAST+DAST+Func |
| 7 | Jenkins, Nexus, Maven | CI Pipeline |
| 8 | Docker, Jenkins | Container CD |
| 9 | Kubernetes, Minikube | K8s Microservices |

### 5 Câu hỏi Ôn tập (Đáp án mẫu)

1. Terraform=Provision, Ansible=Configure → bổ trợ
2. CI=build+test tự động, CD=deploy tự động
3. SAST=phân tích code không chạy, DAST=tấn công app đang chạy
4. Docker=1 container/máy, K8s=hàng trăm containers/nhiều máy
5. Plan→Code→Build→Test→Deploy→Operate→Monitor

---

## Các Lỗi SV Thường Gặp

| # | Lỗi | Cách hướng dẫn |
|---|------|---------------|
| 1 | Minikube không start | Docker Desktop chưa chạy, hoặc thiếu RAM |
| 2 | `ImagePullBackOff` | Mất internet, hoặc image name sai |
| 3 | Frontend không kết nối API | Service name sai — phải là `api-svc` |
| 4 | Pod `CrashLoopBackOff` | Lỗi trong code Node.js, xem log |
| 5 | `minikube service` không mở | Dùng `--url` flag |

## Tiêu chí Chấm điểm

| Tiêu chí | Điểm |
|----------|:----:|
| Minikube + kubectl hoạt động | 15% |
| Deployment 3 replicas + self-healing | 15% |
| Service NodePort | 10% |
| Microservices hoạt động | 25% |
| Scale + Update + Rollback | 15% |
| Debug | 10% |
| Ôn tập tổng hợp | 10% |
| **TỔNG** | **100%** |

🎉 **CHÚC MỪNG HOÀN THÀNH KHÓA HỌC DEVOPS!**
