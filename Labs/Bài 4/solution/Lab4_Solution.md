# Lab 4 — Đáp án (Dành cho Giảng viên)

## Tổng quan
Lab dùng Docker containers làm managed nodes (thay vì VM thật), giúp SV thực hành Ansible không cần cloud account. 3 containers Ubuntu + SSH đóng vai web-server-1, web-server-2, db-server-1.

---

## Kết quả Mong đợi

### ansible all -m ping
```yaml
web-server-1:
  ping: pong
web-server-2:
  ping: pong
db-server-1:
  ping: pong
```

### playbook-webserver.yml
- 5 tasks, 2 hosts = 10 steps
- changed: tasks 2,4 (install Apache + create index.html)
- ok: tasks 1,3,5 (apt cache, service start, firewall)

### playbook-full.yml  
- Web tier: install curl, git, htop, vim + create /opt/myapp/
- All servers: install sysstat, net-tools
- Health check script executable, config.env readable

### Idempotency
Chạy lại playbook → `changed=0` (tất cả đã được cấu hình)

---

## Các Lỗi SV Thường Gặp

| # | Lỗi | Cách hướng dẫn |
|---|------|---------------|
| 1 | `ansible: command not found` | pip install ansible |
| 2 | SSH connection failed | Kiểm tra container running, port mapping |
| 3 | apt update timeout | Container cũ, chạy apt update thủ công trong container |
| 4 | Apache không start | service apache2 status, kiểm tra log |
| 5 | YAML syntax error | Thụt lề phải đúng (2 spaces, không tab!) |

---

## Câu hỏi Vấn đáp

1. **"Ansible khác Terraform thế nào?"** → Terraform PROVISION (tạo server), Ansible CONFIGURE (cài đặt server). Cả 2 bổ trợ nhau.
2. **"Tại sao Ansible agentless mà vẫn quản lý được?"** → Dùng SSH có sẵn trên mọi Linux server, không cần cài agent.
3. **"Idempotency là gì?"** → Chạy 1 lần hay 100 lần, kết quả giống hệt. `changed=0` khi chạy lại.

## Tiêu chí Chấm điểm

| Tiêu chí | Điểm |
|----------|:----:|
| Ansible + Docker OK | 20% |
| Ping 3 hosts | 15% |
| Ad-hoc commands | 15% |
| Playbook webserver OK | 25% |
| Full playbook OK | 15% |
| Cleanup | 10% |
| **TỔNG** | **100%** |
