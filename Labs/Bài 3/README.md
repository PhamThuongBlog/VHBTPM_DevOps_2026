# Lab 3: Cấp phát Hạ tầng Đám mây với Terraform & AWS

## Thông tin chung
- **Bài học:** Bài 3 — Cơ sở Hạ tầng Dưới dạng Mã (IaC)
- **CDR:** 3.2 — Vận dụng IaC trong thiết lập và quản lý cấu hình hạ tầng
- **Mức Bloom:** Vận dụng (Apply)
- **Thời lượng:** 90 phút
- **Hình thức:** Cá nhân

## Mục tiêu
Sau khi hoàn thành lab, sinh viên có thể:
1. Viết được các file cấu hình Terraform (.tf) để khai báo tài nguyên AWS
2. Sử dụng thành thạo quy trình Terraform: init → plan → apply → destroy
3. Cấp phát được máy chủ ảo EC2 và S3 bucket trên AWS bằng mã
4. Truy xuất thông tin tài nguyên đã tạo qua Terraform outputs
5. Dọn dẹp tài nguyên đúng cách để tránh phát sinh chi phí

## Kiến thức tiên quyết
- Đã học Bài 3, phần 3.1 (khái niệm CSHT) và 3.2 (IaC với Terraform)
- Đã có tài khoản AWS (free tier)
- Đã cài đặt: VS Code hoặc trình soạn thảo code bất kỳ

## Nội dung Lab
| Step | Nội dung | Thời gian |
|------|----------|-----------|
| 1 | Chuẩn bị môi trường | 15 phút |
| 2 | Tạo cấu trúc dự án Terraform | 5 phút |
| 3 | Viết file variables.tf | 10 phút |
| 4 | Viết file main.tf (EC2 + S3) | 20 phút |
| 5 | Viết file outputs.tf | 5 phút |
| 6 | Triển khai: init → plan → apply | 20 phút |
| 7 | Kiểm tra kết quả & Dọn dẹp | 15 phút |

## Cấu trúc thư mục
```
4_Labs/Bài 3/
├── README.md                    ← File này
├── Lab3_HuongDan.md            ← Hướng dẫn chi tiết từng bước
├── configs/                     ← File cấu hình Terraform mẫu
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── scripts/                     ← Script hỗ trợ
│   ├── setup.sh                ← Cài đặt môi trường (macOS/Linux)
│   ├── setup.ps1               ← Cài đặt môi trường (Windows)
│   ├── verify.sh               ← Kiểm tra kết quả
│   └── cleanup.sh              ← Dọn dẹp tài nguyên
├── screenshots/                 ← Ảnh minh họa kết quả từng bước
└── solution/                    ← Đáp án (cho giảng viên)
    └── Lab3_Solution.md
```
