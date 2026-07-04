# Lab 9: Kubernetes & Triển khai Microservices — Ôn tập Tổng hợp

## Thông tin chung
- **Bài học:** Bài 9 — Quản lý Container với Kubernetes & Ôn tập
- **CDR:** 9.1 (Kubernetes) + 9.2 (Microservices) + Tổng ôn CDR 1-8
- **Mức Bloom:** Vận dụng (Apply) + Phân tích (Analyze)
- **Thời lượng:** 120 phút (lab dài nhất — có phần ôn tập tổng hợp)
- **Hình thức:** Cá nhân

## Mục tiêu
Sau lab này, sinh viên có thể:
1. Cài đặt và sử dụng **Minikube** (Kubernetes local)
2. Triển khai **Pod, Deployment, Service** trên K8s
3. Deploy ứng dụng **microservices** (2 services: API + Frontend) lên K8s
4. Sử dụng `kubectl` để quản lý, debug, scale ứng dụng
5. Ôn tập tổng hợp: vẽ **DevOps Pipeline hoàn chỉnh** từ Bài 1→9

## Kiến thức tiên quyết
- Đã học Bài 8 (Docker, Container), Bài 7 (CI/CD), Bài 5 (Git)
- Đã cài đặt: Docker Desktop (có Kubernetes built-in HOẶC Minikube)

## Kiến trúc Lab — Microservices trên K8s

```
┌─────────────────────────────────────────────────────────┐
│                    KUBERNETES CLUSTER                     │
│                                                          │
│  ┌──────────────────────┐  ┌──────────────────────┐     │
│  │  Deployment: api     │  │  Deployment: frontend │     │
│  │  Replicas: 2         │  │  Replicas: 2         │     │
│  │  ┌──────┐ ┌──────┐   │  │  ┌──────┐ ┌──────┐   │     │
│  │  │Pod 1 │ │Pod 2 │   │  │  │Pod 1 │ │Pod 2 │   │     │
│  │  │:3000 │ │:3000 │   │  │  │:8080 │ │:8080 │   │     │
│  │  └──────┘ └──────┘   │  │  └──────┘ └──────┘   │     │
│  └──────────┬───────────┘  └──────────┬───────────┘     │
│             │                         │                  │
│             ▼                         ▼                  │
│  ┌──────────────────────┐  ┌──────────────────────┐     │
│  │  Service: api-svc    │  │  Service: frontend-svc│     │
│  │  Type: ClusterIP     │  │  Type: NodePort       │     │
│  │  Port: 3000          │  │  Port: 8080→30080     │     │
│  └──────────────────────┘  └──────────────────────┘     │
│                                    │                     │
└────────────────────────────────────┼─────────────────────┘
                                     │
                              ┌──────▼──────┐
                              │  Browser    │
                              │ localhost:  │
                              │   30080     │
                              └─────────────┘
```

## Nội dung Lab
| Step | Nội dung | Thời gian |
|------|----------|-----------|
| 1 | Cài đặt Minikube + kubectl | 15 phút |
| 2 | Pod & Deployment — Chạy app đầu tiên trên K8s | 20 phút |
| 3 | Service & Networking — Expose ứng dụng | 15 phút |
| 4 | Microservices Deployment — API + Frontend | 25 phút |
| 5 | Scale, Update & Rollback | 15 phút |
| 6 | Debug & Monitoring cơ bản | 10 phút |
| 7 | ÔN TẬP TỔNG HỢP — DevOps Pipeline hoàn chỉnh | 20 phút |
