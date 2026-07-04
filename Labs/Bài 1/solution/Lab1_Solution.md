# Lab 1 — Đáp án (Dành cho Giảng viên)

> **KHÔNG chia sẻ file này cho sinh viên!**

---

## Tổng quan

Lab 1 là **lab intro** — nhẹ nhất trong tất cả các lab DevOps. Mục đích: cho sinh viên **trải nghiệm DevOps end-to-end** mà không bị ngợp bởi công cụ phức tạp. Dùng GitHub Actions + GitHub Pages (hoàn toàn miễn phí).

---

## Kết quả Mong đợi

### Repository
- Public repo: `devops-lab1-portfolio`
- Có `index.html` (website portfolio đơn giản)
- Có `.github/workflows/deploy.yml` (CI/CD pipeline)
- Tab Actions hiển thị pipeline success ✅

### Website
- URL: `https://<USER>.github.io/devops-lab1-portfolio/`
- Hiển thị portfolio với CSS gradient, badges
- Khi sửa code + push → website tự động cập nhật sau ~10 giây

### Pipeline
```
🚀 Deploy to GitHub Pages
  └─ build-and-deploy (ubuntu-latest)
      ├─ 📦 Checkout Code ............. ✅
      ├─ 🧪 Validate HTML ............. ✅
      └─ 🚀 Deploy to GitHub Pages .... ✅
```

---

## Đáp án Bảng So sánh DevOps vs Truyền thống

| Tiêu chí | Cách THỦ CÔNG | Cách DEVOPS |
|----------|--------------|-------------|
| Làm sao để deploy? | Copy file qua USB/FTP/gửi email cho Ops | `git push` → pipeline tự deploy |
| Mất bao lâu? | 15-30 phút (thủ công từng bước) | ~10 giây (tự động) |
| Ai làm deploy? | Developer hoặc Ops engineer | GitHub Actions (bot) |
| Có sai sót không? | Có — quên file, sai config, sai version | Không — pipeline chạy nhất quán 100% |
| Rollback nếu lỗi? | Tìm bản cũ trong email/USB → deploy lại | `git revert` + push → tự động |
| Làm sao biết thành công? | Mở browser check thủ công | Actions tab hiển thị ✅ + email notification |

---

## Các Lỗi Sinh viên Thường Gặp

| # | Lỗi | Nguyên nhân | Cách hướng dẫn |
|---|------|------------|----------------|
| 1 | Pipeline không trigger | Push sai branch (không phải `main`) | Kiểm tra: `git branch` → phải là `main` |
| 2 | Website 404 | Chưa cấu hình GitHub Pages source | Settings → Pages → Source: `gh-pages` |
| 3 | Website hiển thị README thay vì index.html | `publish_dir` sai trong workflow | Sửa `publish_dir: ./` (thư mục gốc) |
| 4 | Permission denied khi push | Dùng HTTPS không có token | Tạo PAT hoặc dùng SSH |
| 5 | File workflow không chạy | Sai đường dẫn thư mục | Phải là `.github/workflows/` (có dấu chấm!) |
| 6 | Pipeline lỗi "index.html NOT found" | File không nằm ở thư mục gốc | `index.html` phải ở root của repo |
| 7 | Website không load CSS | GitHub Pages không hỗ trợ server-side | CSS phải inline trong `<style>` hoặc file `.css` cùng thư mục |
| 8 | `gh-pages` branch không tự tạo | Actions chưa chạy lần đầu | Chạy pipeline lần đầu → branch tự tạo |

---

## Câu hỏi Vấn đáp

1. **"GitHub Actions là gì? Nó miễn phí không?"**
   → GitHub Actions là CI/CD service tích hợp sẵn trong GitHub. Miễn phí 2,000 phút/tháng cho repo public, đủ dùng cho lab.

2. **"Pipeline trong lab này có mấy stages? Mỗi stage làm gì?"**
   → 3 steps trong 1 job: Checkout code → Validate HTML → Deploy to GitHub Pages.

3. **"DevOps khác gì với cách làm truyền thống?"**
   → DevOps tự động hóa build/test/deploy qua pipeline code. Truyền thống làm thủ công từng bước. DevOps nhanh hơn, ít lỗi hơn, repeatable.

4. **"Nếu website bị lỗi sau khi deploy, làm sao để sửa?"**
   → Sửa code → commit → push → pipeline tự deploy bản mới. Nếu cần rollback: `git revert` commit lỗi → push.

5. **"Tại sao chọn GitHub Pages cho lab này mà không dùng AWS?"**
   → GitHub Pages miễn phí, không cần thẻ tín dụng, setup 5 phút. AWS cần tài khoản + credit card. Bài 3 mới dùng AWS.

---

## Tiêu chí Chấm điểm

| Tiêu chí | Điểm | Cách chấm |
|----------|:----:|-----------|
| Repository | 15 | Public, có README + index.html |
| Pipeline YAML | 25 | `.github/workflows/deploy.yml` đúng cấu trúc |
| Website Online | 35 | `*.github.io` URL hoạt động, hiển thị portfolio |
| CI/CD hoạt động | 15 | Push code → Actions chạy → website update |
| Bảng so sánh | 10 | So sánh đúng DevOps vs Traditional |
| **TỔNG** | **100** | |

Xếp loại:
- **Giỏi (≥85):** Đủ + bài mở rộng (Lighthouse CI / multi-page)
- **Khá (70-84):** Website online, CI/CD hoạt động
- **TB (50-69):** Có repo + index.html nhưng pipeline chưa chạy
- **Yếu (<50):** Chưa push được code lên GitHub
