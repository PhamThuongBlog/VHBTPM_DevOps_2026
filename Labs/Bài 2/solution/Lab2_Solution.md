# Lab 2 — Đáp án (Dành cho Giảng viên)

> **KHÔNG chia sẻ file này cho sinh viên!**

---

## Tổng quan

Lab 2 tập trung vào **nguyên tắc CALMS** — nền tảng lý thuyết của DevOps. Khác với các lab kỹ thuật, lab này có 50% lý thuyết/thực hành nhẹ + 50% tự đánh giá/phân tích. Mục đích: SV hiểu **tại sao** DevOps quan trọng trước khi đi sâu vào **làm thế nào** ở các lab sau.

---

## Kết quả Mong đợi

### Automation Script
- Chạy trên cả Windows (.ps1) và macOS/Linux (.sh)
- Tạo cấu trúc: `src/`, `tests/`, `docs/`
- Tạo `.gitignore` + `README.md`
- Thông báo thời gian chạy (Linux/Mac: `${SECONDS}s`)

### Docker App
```json
{"message":"Hello from Docker!","lab":"DevOps Lab 2 — Lean Principle",...}
```
- Container chạy Node.js 18 trên Alpine Linux
- Platform luôn là `linux` (dù chạy trên Windows/macOS) → chứng minh tính nhất quán

### CALMS Self-Assessment
- SV tự chấm điểm 5 trụ cột (mỗi cái 1-5)
- Viết 3 hành động cải thiện cụ thể (không chung chung)

---

## Bảng CALMS Đáp án Mẫu (cho GV tham khảo)

| Nguyên tắc | SV năm 3-4 (dự kiến) | Team DevOps thực thụ |
|-----------|:---:|:---:|
| Culture | 2-3 | 4-5 |
| Automation | 2-3 | 4-5 |
| Lean | 2-3 | 4-5 |
| Measurement | 1-2 | 3-5 |
| Sharing | 2-3 | 4-5 |
| **Tổng** | **10-14/25** | **19-25/25** |

SV thường đạt 10-14/25 — đó là BÌNH THƯỜNG và MONG ĐỢI. Mục tiêu của khóa học là nâng lên 18-20/25 sau 9 bài.

---

## Các Lỗi Sinh viên Thường Gặp

| # | Lỗi | Nguyên nhân | Cách hướng dẫn |
|---|------|------------|----------------|
| 1 | Docker không chạy | Docker Desktop chưa start | Mở Docker Desktop, đợi "Engine running" |
| 2 | `docker build` lỗi permission | Linux không thêm user vào docker group | `sudo usermod -aG docker $USER` + logout/login |
| 3 | `.sh` script không chạy trên Windows | Git Bash chưa cài | Dùng file `.ps1` hoặc cài Git Bash |
| 4 | SV không hiểu CALMS | Chỉ đọc slide, chưa thực hành | Cho SV mô tả lại CALMS bằng ví dụ THỰC TẾ của chính họ |
| 5 | Toolchain map thiếu công cụ | Chưa tổng hợp kiến thức | Gợi ý: nhìn lại các lab đã làm (Lab 1, 2, 3...) |
| 6 | Script quá đơn giản | SV nghĩ automation = copy/paste | Khuyến khích thêm: check OS, auto-install dependencies, error handling |

---

## Câu hỏi Vấn đáp

1. **"CALMS là gì? Tại sao 5 yếu tố này quan trọng?"**
   → Culture, Automation, Lean, Measurement, Sharing. Đây là 5 trụ cột — thiếu 1 cái, DevOps không thành công. Ví dụ: có Automation nhưng không có Sharing → mỗi team tự viết script riêng, trùng lặp.

2. **"Docker giải quyết vấn đề gì trong nguyên tắc Lean?"**
   → Loại bỏ lãng phí "It works on my machine" — môi trường giống hệt từ dev→test→prod. Không cần cài đặt thủ công, không version conflict.

3. **"Automation script khác gì với CI/CD pipeline?"**
   → Script chạy 1 lần (setup env). CI/CD pipeline chạy liên tục mỗi khi có code thay đổi (Jenkins, GitHub Actions). Cả 2 đều là Automation.

4. **"Làm sao để đo lường (Measurement) DevOps maturity?"**
   → DORA metrics: Deployment Frequency, Lead Time for Changes, Mean Time to Recovery, Change Failure Rate.

5. **"Tại sao Culture là trụ cột KHÓ NHẤT trong CALMS?"**
   → Vì liên quan đến CON NGƯỜI — thay đổi mindset, phá bỏ silo, xây dựng lòng tin. Tools có thể mua, culture phải xây dựng.

---

## Tiêu chí Chấm điểm

| Tiêu chí | Điểm | Cách chấm |
|----------|:----:|-----------|
| Toolchain cài đặt | 20 | `git --version`, `docker --version`, `code --version` |
| Automation script | 25 | Script chạy OK, tạo đủ cấu trúc |
| Docker app | 25 | `docker build` + `docker run` OK, `curl` trả JSON |
| Toolchain map | 15 | Sơ đồ ≥ 6 giai đoạn, ≥ 10 công cụ |
| CALMS assessment | 15 | Bảng tự đánh giá + 3 hành động |
| **TỔNG** | **100** | |

Xếp loại:
- **Giỏi (≥85):** Đủ + bài mở rộng (multi-stage build / CI/CD Docker)
- **Khá (70-84):** Đủ các bước, Docker chạy, CALMS phân tích tốt
- **TB (50-69):** Làm được 3/5 bước
- **Yếu (<50):** Chưa cài Docker, chưa viết script
