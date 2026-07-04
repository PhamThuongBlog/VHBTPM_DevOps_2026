# 🏆 CAPSTONE PROJECT — Đáp án (Dành cho Giảng viên)

## Tổng quan

Capstone yêu cầu SV xây dựng DevOps pipeline end-to-end cho ứng dụng **Student Manager** (Spring Boot + Java 17). Pipeline 9 stages tự động qua Jenkins, tích hợp Maven, JUnit, SonarQube, Nexus, Docker, Docker Hub, ZAP, Newman.

---

## Kết quả Mong đợi

### 1. Infrastructure
```
CONTAINER ID   NAMES                STATUS
abc12345       capstone-jenkins     Up (healthy)
def67890       capstone-nexus       Up (healthy)
ghi11111       capstone-sonarqube   Up (healthy)
jkl22222       student-manager      Up (healthy)
```

### 2. Jenkins Pipeline (9 stages — tất cả xanh)
```
1. Checkout → 2.Build → 3.Unit Test → 4.Static Analysis → 5.Package
→ 6.Publish Nexus → 7.Docker Build → 8.Docker Push → 9.Deploy
```

### 3. SonarQube Dashboard
| Bugs | Vulnerabilities | Code Smells | Coverage |
|:----:|:--------------:|:-----------:|:--------:|
| 0 | 0 | ≤ 15 | ≥ 60% |

### 4. curl localhost:8080/api/students
```json
{"success":true,"data":[...3 students...],"total":3,"service":"student-manager","version":"1.0.0"}
```

### 5. DevOps Vòng lặp
SV demo được: push code → pipeline tự chạy → app deploy → monitor → tạo issue → fix → push → pipeline chạy lại

---

## Vấn đề Thường gặp

| # | Vấn đề | Cách xử lý |
|---|--------|-----------|
| 1 | SonarQube phân tích lỗi (Java version) | Kiểm tra Maven chạy Java 17 |
| 2 | `mvn deploy` lỗi 401 Nexus | Cấu hình `~/.m2/settings.xml` server credentials |
| 3 | Docker build không tìm thấy .jar | Chạy `mvn package -DskipTests` trước |
| 4 | Port 8080 already in use | Đổi `APP_PORT` trong Jenkinsfile |
| 5 | `docker push` lỗi permission | `docker login` với Docker Hub token |
| 6 | Memory không đủ (4 containers) | Docker Desktop → 8GB RAM minimum |

---

## Rubric Chấm điểm

| # | Tiêu chí | Điểm tối đa | Chi tiết |
|---|----------|:---:|----------|
| 1 | **Infrastructure** — 3 services running | 10 | Jenkins + Nexus + SonarQube |
| 2 | **Code** — App Spring Boot chạy OK | 10 | `mvn spring-boot:run` → health check pass |
| 3 | **Git** — Code lên GitHub + Git Flow | 10 | Có main + develop branch |
| 4 | **CI Pipeline** — Jenkins 9 stages | 20 | Tất cả stages xanh |
| 5 | **Test** — JUnit 7/7 pass | 10 | Surefire reports in Jenkins |
| 6 | **SonarQube** — Code quality scan | 10 | Dashboard có metrics |
| 7 | **Nexus** — Artifact uploaded | 10 | Browse thấy .jar trong Nexus |
| 8 | **Docker** — Image build + push | 10 | Docker Hub có image |
| 9 | **Deploy** — App running on Docker | 10 | `curl localhost:8080/api/students` hoạt động |
| **TỔNG** | | **100** | |

---

## Câu hỏi Bảo vệ

1. **"Mô tả DevOps pipeline của bạn từ đầu đến cuối"**
2. **"Tại sao cần cả SonarQube (SAST) và ZAP (DAST)?"** → Một cái phân tích code tĩnh, một cái test app đang chạy
3. **"Jenkins làm gì trong pipeline?"** → Orchestrator, gọi Maven/SonarQube/Docker theo thứ tự
4. **"Làm sao để rollback nếu deploy lỗi?"** → `docker run` lại image cũ, Jenkins có thể tự động
5. **"Vòng lặp DevOps hoạt động thế nào?"** → Monitor → Feedback → Plan → Code → CI/CD → Monitor

## Xếp loại

- **Giỏi (≥85):** 9 stages xanh + ZAP report + Newman pass + vòng lặp feedback
- **Khá (70-84):** 7-8 stages xanh, app deploy OK
- **TB (50-69):** Pipeline chạy nhưng 1-2 stages fail
- **Yếu (<50):** Chưa dựng được Jenkins, app chưa deploy được

🎉 **CAPSTONE HOÀN THÀNH — CHÚC MỪNG TỐT NGHIỆP KHÓA DEVOPS!**
