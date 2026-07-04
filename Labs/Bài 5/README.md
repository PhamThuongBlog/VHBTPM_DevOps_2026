# Lab 5: Quản lý Mã nguồn với Git Flow & Code Review trên GitHub

## Thông tin chung
- **Bài học:** Bài 5 — Quản lý Mã nguồn với Git & GitHub
- **CDR:** 5.2 — Vận dụng nguyên lý quản lý mã nguồn dự án với Git, GitHub
- **Mức Bloom:** Vận dụng (Apply)
- **Thời lượng:** 90 phút
- **Hình thức:** Nhóm 2 người (Pair Programming)

## Mục tiêu
Sau khi hoàn thành lab, sinh viên có thể:
1. Khởi tạo repository Git, kết nối với GitHub remote
2. Thực hiện thành thạo quy trình: add → commit → push → pull
3. Áp dụng Git Flow: main, develop, feature, hotfix branches
4. Tạo Pull Request và thực hiện Code Review trên GitHub
5. Giải quyết xung đột (merge conflicts) khi làm việc nhóm
6. Sử dụng .gitignore và viết README.md chuẩn

## Kiến thức tiên quyết
- Đã học Bài 5 (SCM, Git, GitHub, Git Flow)
- Đã cài đặt: Git, VS Code, tài khoản GitHub

## Kịch bản Lab
Sinh viên đóng vai **2 developer** trong 1 team phát triển ứng dụng web "Student Manager". Team sử dụng Git Flow để quản lý code:
- **Dev A**: Tạo repo, thiết lập Git Flow, phát triển feature "add-student"
- **Dev B**: Clone repo, phát triển feature "search-student", tạo PR, review code của Dev A
- Cả hai: Giải quyết merge conflict, hoàn thiện quy trình

## Nội dung Lab
| Step | Nội dung | Thời gian |
|------|----------|-----------|
| 1 | Cài đặt & Cấu hình Git + GitHub | 10 phút |
| 2 | Khởi tạo Repository & Kết nối GitHub | 10 phút |
| 3 | Git Cơ bản: add → commit → push → pull | 15 phút |
| 4 | Git Flow: Tạo & Quản lý Nhánh | 15 phút |
| 5 | Pull Request & Code Review | 20 phút |
| 6 | Giải quyết Merge Conflict | 10 phút |
| 7 | Tổng kết & Dọn dẹp | 10 phút |

## Cấu trúc thư mục
```
4_Labs/Bài 5/
├── README.md                     ← File này
├── Lab5_HuongDan.md             ← Hướng dẫn chi tiết từng bước
├── scripts/
│   ├── setup.ps1 / setup.sh      ← Cài đặt Git
│   ├── verify.sh                 ← Kiểm tra kết quả
│   └── cleanup.sh                ← Dọn dẹp
├── screenshots/                  ← Ảnh minh họa
└── solution/                     ← Đáp án GV
    └── Lab5_Solution.md
```
