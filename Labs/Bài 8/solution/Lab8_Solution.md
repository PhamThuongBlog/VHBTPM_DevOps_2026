# Lab 8 — Đáp án (Dành cho Giảng viên)

> **KHÔNG chia sẻ file này cho sinh viên!**
> **Lab gốc vẫn giữ:** `1_Lectures/Bài 8_OK/Bài 8_CI_CD_Part2_Lab.pdf`

---

## Tổng quan
Lab 8 tập trung vào CD (Continuous Delivery) — deploy ứng dụng bằng Docker. Khác với CI (Bài 7) kiểm tra code, CD đưa code ra production. Lab dùng Docker multi-stage build + Docker Compose + Jenkins CD pipeline.

---

## Kết quả Mong đợi

### Docker Images
```
devops-lab8-app   1.0    ~80MB   (multi-stage, tối ưu)
devops-lab8-app   fat    ~200MB  (không multi-stage)
```

### docker compose ps
```
NAME          STATUS
lab8-app      Up
lab8-redis    Up
lab8-nginx    Up
```

### Jenkins CD Pipeline (6 stages)
```
Checkout → Docker Build → Scan → Push → Deploy → Verify
   ✅         ✅           ✅      ✅       ✅        ✅
```

### curl localhost:3000/
```json
{"message":"🚀 DevOps Lab 8 — CD Pipeline","version":"2.0.0","env":"production",...}
```

---

## Đáp án CI vs CD

| Tiêu chí | CI (Bài 7) | CD (Bài 8) |
|----------|-----------|-----------|
| Mục đích | Kiểm tra code có lỗi không | Đưa code đến người dùng |
| Output | File .jar | Container đang chạy |
| Công cụ | Maven, SonarQube, Nexus | Docker, Docker Hub |
| Tần suất | Mỗi commit | Mỗi lần CI pass |

---

## Các Lỗi SV Thường Gặp

| # | Lỗi | Cách hướng dẫn |
|---|------|---------------|
| 1 | `docker build` permission denied | `sudo usermod -aG docker $USER` |
| 2 | `docker push` denied | Chưa docker login hoặc token sai |
| 3 | Jenkins không chạy được docker | `docker exec -u root jenkins chmod 666 /var/run/docker.sock` |
| 4 | Port 3000 already in use | Đổi APP_PORT trong Jenkinsfile |
| 5 | Nginx 502 | App chưa sẵn sàng — đợi vài giây |

---

## Câu hỏi Vấn đáp

1. **"Multi-stage build giúp gì?"** → Giảm kích thước image (bỏ devDependencies, build tools)
2. **"CI khác CD thế nào?"** → CI = kiểm tra code, CD = deploy code ra production
3. **"Tại sao cần Docker registry?"** → Lưu trữ & chia sẻ Docker images giữa các môi trường

## Tiêu chí Chấm điểm

| Tiêu chí | Điểm |
|----------|:----:|
| Docker image build multi-stage | 20% |
| Compose 3 services chạy | 20% |
| Push Docker Hub | 15% |
| Jenkins CD pipeline 6 stages | 25% |
| CI vs CD hiểu đúng | 10% |
| Cleanup | 10% |
| **TỔNG** | **100%** |
