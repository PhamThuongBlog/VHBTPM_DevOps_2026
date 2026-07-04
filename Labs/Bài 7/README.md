# Lab 7: Triển khai CI Pipeline với Jenkins, Nexus & SonarQube

## Thông tin chung
- **Bài học:** Bài 7 — Tích hợp Liên tục (Continuous Integration)
- **CDR:** 7.2 — Vận dụng triển khai CI pipeline với Jenkins + Nexus
- **Mức Bloom:** Vận dụng (Apply)
- **Thời lượng:** 90 phút
- **Hình thức:** Cá nhân

## Mục tiêu
Sau khi hoàn thành lab, sinh viên có thể:
1. Dựng được Jenkins Server và Nexus Repository bằng Docker
2. Viết được Jenkinsfile (Declarative Pipeline) chuẩn CI
3. Cấu hình Jenkins Pipeline tự động: Checkout → Build → Test → Archive
4. Tích hợp được SonarQube để phân tích mã nguồn tĩnh trong pipeline
5. Đẩy artifact (file .jar) lên Nexus Repository
6. Kích hoạt pipeline tự động qua GitHub Webhook

## Kiến thức tiên quyết
- Đã học Bài 5 (Git, GitHub) và Bài 7 (CI lý thuyết)
- Đã cài đặt: Docker Desktop, Git, VS Code

## Kiến trúc Lab

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Jenkins    │────▶│  SonarQube  │────▶│   Nexus     │
│  CI Server  │     │  Code Scan  │     │  Repository │
│  port 8080  │     │  port 9000  │     │  port 8081  │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │                                        ▲
       │ git clone                              │ upload .jar
       ▼                                        │
┌─────────────┐                                 │
│  GitHub Repo│─────────────────────────────────┘
│  (source)   │
└─────────────┘

CI Pipeline: Checkout → Build (Maven) → Test → SonarQube Scan → Archive → Publish to Nexus
```

## Nội dung Lab
| Step | Nội dung | Thời gian |
|------|----------|-----------|
| 1 | Chuẩn bị môi trường: Docker + Docker Compose | 10 phút |
| 2 | Dựng Jenkins + Nexus + SonarQube với Docker Compose | 15 phút |
| 3 | Tạo sample Java project với Maven | 10 phút |
| 4 | Viết Jenkinsfile (Declarative Pipeline) | 15 phút |
| 5 | Cấu hình Jenkins Pipeline Job | 15 phút |
| 6 | Chạy Pipeline & Kiểm tra kết quả | 15 phút |
| 7 | Dọn dẹp | 10 phút |

## Cấu trúc thư mục
```
4_Labs/Bài 7/
├── README.md                       ← File này
├── Lab7_HuongDan.md               ← Hướng dẫn chi tiết từng bước
├── configs/
│   ├── docker-compose.yml          ← Jenkins + Nexus + SonarQube stack
│   ├── Jenkinsfile                 ← Pipeline chuẩn mẫu
│   └── sample-java-app/           ← Dự án Java/Maven mẫu
│       ├── pom.xml
│       └── src/main/java/...
├── scripts/
│   ├── setup.sh / setup.ps1        ← Cài đặt tự động
│   ├── verify.sh                   ← Kiểm tra pipeline
│   └── cleanup.sh                  ← Dọn dẹp containers
├── screenshots/                    ← Ảnh minh họa
└── solution/                       ← Đáp án GV
    └── Lab7_Solution.md
```
