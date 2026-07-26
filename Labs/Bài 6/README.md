# Lab 6: Kiểm thử & Phân tích Mã nguồn Tĩnh trong DevOps

## Thông tin chung
- **Bài học 6:** Kiểm thử & Phân tích Mã nguồn Tĩnh
- **CDR:** 6.2 — Vận dụng nguyên lý kiểm thử trong DevOps
- **Mức Bloom:** Vận dụng (Apply)
- **Thời lượng:** 90 phút
- **Hình thức:** Cá nhân

## Mục tiêu
Sau khi hoàn thành lab, sinh viên có thể:
1. Viết và chạy API tests với Postman/Newman CLI
2. Quét lỗ hổng bảo mật web với OWASP ZAP (DAST)
3. Phân tích mã nguồn tĩnh với SonarQube (SAST)
4. Phân biệt được 3 loại kiểm thử: Functional vs Security vs Static Analysis
5. Tích hợp kiểm thử vào CI pipeline (Newman + ZAP + SonarQube automation)

## Kiến thức tiên quyết
- Đã học Bài 6 (Kiểm thử động vs Phân tích tĩnh)
- Đã cài đặt: Node.js ≥ 18, Docker Desktop, Postman

## Kiến trúc Lab — 3 Loại Kiểm thử

```
┌──────────────────────────────────────────────────────────┐
│                   DEVOPS TESTING LAB                     │
│                                                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐   │
│  │   POSTMAN    │  │  OWASP ZAP   │  │  SONARQUBE   │   │
│  │  (Dynamic)   │  │   (DAST)     │  │   (SAST)     │   │
│  │              │  │              │  │              │   │
│  │ Kiểm thử API │  │ Quét bảo mật │  │ Phân tích    │   │
│  │ chức năng    │  │ tự động      │  │ mã nguồn tĩnh│   │
│  │              │  │              │  │              │   │
│  │ ✓ Status code│  │ ✓ SQL Inj.   │  │ ✓ Bugs       │   │
│  │ ✓ Response   │  │ ✓ XSS        │  │ ✓ Code Smells│   │
│  │ ✓ Schema     │  │ ✓ CSRF       │  │ ✓ Security   │   │
│  │ ✓ Performance│  │ ✓ Auth issues│  │   Hotspots   │   │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘   │
│         │                 │                 │            │
│         ▼                 ▼                 ▼            │
│  ┌──────────────────────────────────────────────────┐   │
│  │          CI PIPELINE (Automation)                 │   │
│  │  Code → Build → SAST → Unit Test → DAST → Report │   │
│  └──────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

## Nội dung Lab
| Step | Nội dung | Công cụ | Thời gian |
|------|----------|---------|-----------|
| 1 | Chuẩn bị môi trường + Sample API | Node.js | 10 phút |
| 2 | Kiểm thử API với Postman + Newman CLI | Postman | 20 phút |
| 3 | Kiểm thử Bảo mật với OWASP ZAP | ZAP | 20 phút |
| 4 | Phân tích Mã nguồn Tĩnh với SonarQube | SonarQube | 20 phút |
| 5 | Tự động hóa — Tích hợp vào CI Pipeline | Newman+ZAP+Sonar | 10 phút |
| 6 | So sánh 3 loại kiểm thử — Báo cáo tổng hợp | — | 10 phút |

## Cấu trúc thư mục
```
4_Labs/Bài 6/
├── README.md
├── Lab6_HuongDan.md
├── configs/
│   ├── sample-api/               ← Sample Node.js API
│   │   ├── package.json
│   │   ├── server.js
│   │   └── ...
│   ├── postman/                   ← Postman collection
│   │   └── Student-API-Tests.json
│   └── sonar-project.properties  ← SonarQube config
├── scripts/
│   ├── setup.sh / setup.ps1
│   ├── verify.sh
│   └── cleanup.sh
└── solution/
    └── Lab6_Solution.md
```
