# 🏆 CAPSTONE PROJECT: DevOps End-to-End Pipeline

## Thông tin chung
- **Bài học:** Tổng hợp Bài 1 → Bài 9 (Vận hành & Bảo trì phần mềm)
- **CDR:** Vận dụng toàn bộ vòng đời DevOps — Plan → Code → Build → Test → Scan → Package → Release → Deploy → Operate → **Monitor** → (quay lại) Plan
- **Mức Bloom:** Sáng tạo (Create)
- **Thời lượng:** 180 phút (3 tiết)
- **Hình thức:** Nhóm 2–3 người
- **Ứng dụng:** Student Manager — Spring Boot 3 + Java 17 REST API

## Mục tiêu
Sau khi hoàn thành capstone, sinh viên có thể:
1. Dựng được hạ tầng DevOps đầy đủ (Jenkins + Nexus + SonarQube + ELK + Prometheus/Grafana)
2. Viết được Jenkinsfile **14 stage** khép kín vòng đời DevOps
3. **Giải thích được vai trò của Vận hành & Bảo trì phần mềm trong từng giai đoạn pipeline**
4. Kích hoạt pipeline tự động qua GitHub Actions
5. Triển khai và giám sát ứng dụng thật với ELK + Prometheus + Grafana

## Kiến thức tiên quyết
- Đã hoàn thành Bài 1–9 (đặc biệt Bài 6 Test/SAST, Bài 7 CI, Bài 8 CD)
- Đã cài: Docker Desktop, Git, JDK 17, Maven, Node.js (Newman)

---

## 🎯 Vận hành & Bảo trì phần mềm trong Jenkins DevOps Pipeline

> **Luận điểm cốt lõi:** Jenkins Pipeline **chính là** quy trình *vận hành & bảo trì phần mềm* đã được **tự động hoá**. Mỗi stage trong pipeline không chỉ "build cho xong" mà là một hoạt động bảo trì/ vận hành cụ thể, đóng vai trò khác nhau trong **vòng lặp khép kín** của DevOps.

### 1. Ánh xạ: Hoạt động vận hành & bảo trì ↔ Stage trong pipeline

| Stage Jenkins | Loại bảo trì / vận hành | Mô tả (góc nhìn môn học) |
|---|---|---|
| **1. PLAN** | Bảo trì **phòng ngừa** (Preventive) | Lập kế hoạch, quản lý backlog/issue trên GitHub Project → chủ động phòng tránh sự cố, định hướng công việc bảo trì. |
| **2. CODE** | Bảo trì **sửa chữa / thích nghi** | Git Flow + version control → mọi thay đổi được truy vết, phục vụ phân tích nguyên nhân (RCA) khi sự cố. |
| **3. BUILD** | Bảo trì **phòng ngừa** | Compile sớm → phát hiện lỗi ngay từ đầu, giảm chi phí sửa chữa (fail fast, fail cheap). |
| **4. UNIT TEST** | Bảo trì **phòng ngừa + sửa chữa** | Tự động hoá kiểm thử hồi quy (regression) → ngăn lỗi quay lại sau mỗi lần sửa. |
| **5. STATIC ANALYSIS (SAST)** | Bảo trì **phòng ngừa** | SonarQube phân tích mã nguồn tĩnh → phát hiện bug/bảo mật trước khi lên production (shift-left). |
| **6. PACKAGE / 7. PUBLISH** | Vận hành **quản lý cấu hình & phát hành** | Đóng gói & lưu trữ artifact có **phiên bản** (Nexus) → nền tảng cho **rollback** và tái lập trạng thái (reproducibility). |
| **8. DOCKER BUILD / 9. PUSH** | Bảo trì **thích nghi** | Đóng gói vào container → ứng dụng chạy nhất quán trên mọi môi trường (portability). |
| **10. DEPLOY** | Vận hành **triển khai + khôi phục** | Deploy kèm smoke test & **rollback tự động** khi lỗi → đảm bảo tính sẵn sàng (availability/SLA). |
| **11. DAST / 12. API TEST** | Bảo trì **sửa chữa** (an ninh) | ZAP + Newman test app đang chạy → phát hiện lỗ hổng/sự cố *thời gian vận hành*. |
| **13. MONITOR** | **Vận hành (Operation) — trái tim của môn học** | ELK (log tập trung) + Prometheus/Grafana (metrics) → giám sát liên tục, phát hiện & chẩn đoán sự cố. |
| **14. FEEDBACK** | Bảo trì **hoàn thiện** (Perfective) | Tổng hợp findings từ monitor/test → tạo issue → developer cải tiến → vòng lặp tiếp tục. |

### 2. Bốn loại bảo trì phần mềm hiện diện đầy đủ

Theo chuẩn IEEE (ISO/IEC 14764), vòng lặp DevOps thể hiện trọn vẹn 4 loại bảo trì:

- **🔧 Corrective (sửa chữa):** lỗi được phát hiện bởi Test/Scan/DAST (stage 4, 5, 11) rồi được sửa → chính là chuỗi *issue → fix → commit → push → pipeline chạy lại*.
- **🌍 Adaptive (thích nghi):** đổi môi trường (Docker image, cấu hình, port, target cloud) được cô lập trong Docker/Nexus mà không phá vỡ code (stage 7–9).
- **✨ Perfective (hoàn thiện):** cải tiến chất lượng (tăng coverage, bớt code smell) đến từ **Feedback** của SonarQube/Monitor (stage 14 → quay lại Plan).
- **🛡️ Preventive (phòng ngừa):** SAST, unit test, quality gate, healthcheck là những "tấm khiên" ngăn sự cố trước khi xảy ra (stage 4, 5, 10).

### 3. "Operate" là trung tâm — Observability 3 trụ cột

Giai đoạn **Monitor (stage 13)** chính là phần *vận hành* thuần tuý của môn học, bám theo 3 trụ cột **Observability**:

| Trụ cột | Công cụ | Pipeline làm gì |
|---|---|---|
| **Logs** | ELK (Elasticsearch + Logstash + Kibana) | Thu thập log container, đẩy vào ES, truy vấn/trực quan hoá trên Kibana. |
| **Metrics** | Prometheus + Grafana | Kéo metrics từ Spring Boot Actuator (`/actuator/prometheus`), cảnh báo JVM/HTTP trên Grafana. |
| **Traces / Health** | Actuator health + Docker HEALTHCHECK | Kiểm tra trạng thái sống/sẵn sàng để quyết định deploy/rollback. |

> **Kết luận:** Pipeline không kết thúc ở "Deploy thành công". Nó **tiếp tục giám sát**, **phát hiện vấn đề**, **sinh issue**, và **quay lại Plan** — tức là phần mềm được *vận hành và bảo trì liên tục*, đúng bản chất của môn Vận hành & Bảo trì phần mềm.

---

## Tài liệu đi kèm

| File | Mô tả |
|---|---|
| [`CAPSTONE_GUIDE.md`](./CAPSTONE_GUIDE.md) | Hướng dẫn chi tiết 6 giai đoạn, từng bước thực hành |
| [`CAPSTONE_AWS_EC2.md`](./CAPSTONE_AWS_EC2.md) | ☁️ **Mở rộng:** triển khai toàn bộ pipeline trên AWS EC2 thật |
| `configs/Jenkinsfile` | Pipeline 14 stage (đầy đủ vòng đời DevOps) |
| `configs/docker-compose-infra.yml` | Hạ tầng Jenkins + Nexus + SonarQube + ELK + Prometheus + Grafana |
| `configs/prometheus/prometheus.yml` | Cấu hình scrape metrics |
| `.github/workflows/trigger-jenkins.yml` | Trigger Jenkins tự động bằng GitHub Actions |

## Cấu trúc thư mục
```
CAPSTONE_PROJECT/
├── README.md                       ← File này (kèm phân tích Vận hành & Bảo trì PM)
├── CAPSTONE_GUIDE.md               ← Hướng dẫn chính
├── CAPSTONE_AWS_EC2.md             ← Mở rộng: triển khai trên AWS
├── .github/workflows/trigger-jenkins.yml
├── configs/
│   ├── Jenkinsfile                 ← Pipeline 14 stage
│   ├── Dockerfile
│   ├── docker-compose-infra.yml
│   ├── sonar-project.properties
│   └── prometheus/prometheus.yml
├── scripts/
│   ├── capstone-setup.sh
│   ├── capstone-verify.sh
│   ├── capstone-monitor.sh
│   └── capstone-cleanup.sh
├── screenshots/
└── solution/
    └── CAPSTONE_SOLUTION.md
```
