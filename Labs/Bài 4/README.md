# Lab 4: Quản lý Cấu hình Hạ tầng với Ansible

## Thông tin chung
- **Bài học:** Bài 4 — Quản lý Hạ tầng (IaaS với Ansible)
- **CDR:** 4.2 — Vận dụng IaaS trong quản lý cấu hình hạ tầng với Ansible
- **Mức Bloom:** Vận dụng (Apply)
- **Thời lượng:** 90 phút
- **Hình thức:** Cá nhân

## Mục tiêu
Sau lab này, sinh viên có thể:
1. Cài đặt Ansible và hiểu kiến trúc Control Node vs Managed Nodes
2. Viết Ansible Inventory để quản lý nhiều server
3. Sử dụng Ansible Ad-hoc Commands để kiểm tra & quản lý nhanh
4. Viết Ansible Playbook để tự động hóa cấu hình server
5. Áp dụng Ansible Roles để tổ chức code chuẩn DevOps

## Kiến thức tiên quyết
- Đã học Bài 4 (IaC vs IaaS, Ansible concepts)
- Đã cài đặt: Docker Desktop (dùng container làm managed nodes)

## Kiến trúc Lab — Docker làm Managed Nodes
```
┌─────────────────────┐
│   CONTROL NODE      │        ┌──────────────────┐
│   (máy local)       │──SSH──▶│  MANAGED NODES    │
│   Ansible installed │        │  (Docker containers)│
│                     │        │  ┌──────────────┐ │
│  inventory.ini      │        │  │ web-server-1  │ │
│  playbook.yml       │──SSH──▶│  ├──────────────┤ │
│  ansible.cfg        │        │  │ web-server-2  │ │
│                     │        │  ├──────────────┤ │
│                     │──SSH──▶│  │ db-server-1   │ │
└─────────────────────┘        │  └──────────────┘ │
                                └──────────────────┘
```

## Nội dung Lab
| Step | Nội dung | Thời gian |
|------|----------|-----------|
| 1 | Cài đặt Ansible + Dựng Managed Nodes (Docker) | 15 phút |
| 2 | Ansible Inventory — Khai báo server | 10 phút |
| 3 | Ad-hoc Commands — Kiểm tra nhanh | 15 phút |
| 4 | Playbook Cơ bản — Cài đặt & Cấu hình Web Server | 20 phút |
| 5 | Playbook Nâng cao — Multi-server + Variables | 20 phút |
| 6 | Dọn dẹp | 10 phút |
