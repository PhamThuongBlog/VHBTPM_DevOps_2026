# Lab 6 — Đáp án (Dành cho Giảng viên)

> **KHÔNG chia sẻ file này cho sinh viên!**

---

## Tổng quan

Lab yêu cầu sinh viên thực hành **3 loại kiểm thử** trong DevOps trên cùng 1 ứng dụng:
1. **Functional Testing** (Postman/Newman) — kiểm thử API endpoints
2. **DAST** (OWASP ZAP) — quét lỗ hổng bảo mật khi ứng dụng đang chạy
3. **SAST** (SonarQube) — phân tích mã nguồn tĩnh không cần chạy app

Sample API (`server.js`) được thiết kế với **5 lỗi bảo mật cố ý** để ZAP và SonarQube phát hiện.

---

## 5 Lỗi Bảo mật trong server.js

| # | Lỗi | Vị trí | ZAP phát hiện? | SonarQube phát hiện? |
|---|------|--------|:---:|:---:|
| 1 | **Reflected XSS** — Input từ query string bị phản hồi không escape | `/api/search?q=<script>` | ✅ High | ✅ Security Hotspot |
| 2 | **Information Disclosure** — Endpoint debug lộ biến môi trường | `/api/debug` | ✅ Medium | ✅ Security Hotspot |
| 3 | **Mass Assignment** — Cho phép cập nhật tất cả fields | `PUT /api/students/:id` | ⚠️ Indirect | ❌ (cần context) |
| 4 | **Thiếu Input Validation** — Không validate/sanitize POST body | `POST /api/students` | ✅ Medium | ✅ Code Smell |
| 5 | **Missing Security Headers** — Thiếu CSP, X-Frame-Options, HSTS | Tất cả endpoints | ✅ Medium | ❌ (cần config) |

---

## Kết quả Mong đợi

### Newman (5 requests, 12 assertions)

```
❏ GET All Students        → 5/5 assertions pass
❏ GET Student by ID       → 2/2 assertions pass
❏ POST Create Student     → 2/2 assertions pass
❏ GET Not Found (404)     → 2/2 assertions pass
❏ POST Missing Fields     → 1/1 assertion pass

Total: 5/5 requests, 12/12 assertions, 0 failures
```

### ZAP Automated Scan

| Mức | Số lượng | Ví dụ |
|:---:|:--------:|-------|
| High | ≥ 1 | Cross Site Scripting (Reflected) |
| Medium | ≥ 2 | X-Frame-Options Header Not Set, CSP Header Not Set |
| Low | ≥ 2 | Server Leaks Information, Cookie No HttpOnly |

### SonarQube Dashboard

| Metric | Kết quả mong đợi |
|--------|-----------------|
| Bugs | 0-2 (có thể có: unused variable, missing return) |
| Code Smells | 5-15 (magic numbers, long function, inconsistent naming) |
| Security Hotspots | 3-5 (debug endpoint, CORS *, XSS sink) |
| Duplications | 0% |
| Coverage | 0% (chưa có unit test) |

---

## Bảng So sánh 3 Loại Kiểm thử (Đáp án)

| Tiêu chí | Postman/Newman | OWASP ZAP | SonarQube |
|----------|:---:|:---:|:---:|
| **Loại** | Functional Test | DAST (Dynamic Security) | SAST (Static Security) |
| **Chạy ứng dụng?** | ✅ Có | ✅ Có | ❌ Không |
| **Phát hiện gì?** | API sai logic, sai response format, sai status code | XSS, SQL Injection, CSRF, thiếu security headers | Bugs, Code Smells, Security Hotspots, Duplications |
| **Cần source code?** | ❌ Không (chỉ cần API contract) | ❌ Không (chỉ cần URL) | ✅ Có (phân tích code) |
| **Giai đoạn CI** | Sau deploy lên test env | Sau deploy lên test env | Trước build (sớm nhất) |
| **Thời gian chạy** | ~2 giây | ~30-60 giây | ~20-40 giây |
| **Tự động hóa** | ✅ Newman CLI | ✅ ZAP API / zap-full-scan.py | ✅ SonarScanner / sonar-scanner |
| **Phát hiện logic bug?** | ✅ Tốt | ❌ Không | ⚠️ Hạn chế |
| **Phát hiện security bug?** | ❌ Không | ✅ Tốt nhất | ⚠️ Có (pattern-based) |

### Kết luận chính:
- **SAST chạy SỚM NHẤT** (trước build) → phát hiện lỗi trước khi deploy
- **DAST chạy SAU DEPLOY** → phát hiện lỗi runtime (XSS, SQLi cần app chạy mới thấy)
- **Functional Test chạy SAU DEPLOY** → xác nhận API hoạt động đúng logic
- **KHÔNG LOẠI NÀO THAY THẾ ĐƯỢC LOẠI NÀO** → cần cả 3 trong CI pipeline

---

## Các Lỗi Sinh viên Thường Gặp

| # | Lỗi | Nguyên nhân | Cách hướng dẫn |
|---|------|------------|----------------|
| 1 | ZAP không phát hiện lỗi | Quên spider trước active scan | Spider → Active Scan (2 bước bắt buộc) |
| 2 | Newman báo `ECONNREFUSED` | Server chưa chạy | Mở terminal riêng: `node server.js` |
| 3 | SonarQube `Connection refused` | Container chưa sẵn sàng (cần 1-2 phút) | Chạy `docker logs lab6-sonarqube` đợi "SonarQube is operational" |
| 4 | `sonar-scanner: command not found` | Chưa cài | `npm install -g sonarqube-scanner` |
| 5 | ZAP báo "API key required" | ZAP 2.12+ mặc định yêu cầu API key | Tools → Options → API → bỏ tích "Require API key" |
| 6 | Postman collection import lỗi | Định dạng sai | Export v2.1, không dùng v1 |
| 7 | ZAP scan quá lâu (> 5 phút) | Spider crawl quá sâu | Giới hạn maxChildren=10, chỉ scan domain localhost |
| 8 | Port 3000 bị chiếm | App khác đang chạy | Đổi PORT trong server.js hoặc kill app cũ |

---

## Câu hỏi Vấn đáp

1. **"SAST và DAST khác nhau thế nào? Khi nào dùng cái nào?"**
   → SAST phân tích code không chạy app (sớm, trước build). DAST tấn công app đang chạy (sau deploy). Cả 2 bổ trợ nhau — SAST tìm lỗi sớm, DAST tìm lỗi runtime.

2. **"Tại sao SonarQube không phát hiện được XSS trong `/api/search`?"**
   → Vì XSS chỉ xảy ra khi app CHẠY với input độc hại. SonarQube phân tích code TĨNH → không biết được runtime behavior. ZAP mới phát hiện được vì nó thực sự gửi payload `<script>alert(1)</script>`.

3. **"Postman test khác gì ZAP scan?"**
   → Postman kiểm tra: API có hoạt động đúng logic không? (status 200, response đúng format). ZAP kiểm tra: API có lỗ hổng bảo mật không? (XSS, injection).

4. **"Trong CI pipeline, nên chạy theo thứ tự nào?"**
   → SAST (SonarQube) → Build → Unit Test → Deploy test env → Functional Test (Newman) → DAST (ZAP). SAST trước vì nhanh và rẻ nhất để fix.

5. **"Làm sao để ZAP chỉ báo lỗi MỚI (không báo lỗi cũ)?"**
   → Dùng ZAP Baseline Scan: chạy scan lần đầu làm baseline, lần sau chỉ alert những lỗi xuất hiện MỚI so với baseline.

---

## Tiêu chí Chấm điểm Chi tiết

| Tiêu chí | Điểm | Cách chấm cụ thể |
|----------|:----:|------------------|
| Sample API chạy | 15 | `curl localhost:3000/api/students` trả về JSON đúng |
| Postman 5 requests | 25 | Newman output: 5/5 requests, ≥ 10 assertions pass |
| ZAP scan | 25 | Có zap-report.html, ≥ 3 alerts (cần ≥ 1 High/Medium) |
| SonarQube | 20 | Dashboard có project devops-lab6 với Bugs + Code Smells |
| CI Script | 10 | ci-test.sh chạy tuần tự ≥ 3 stages |
| Bảng so sánh | 5 | Bảng so sánh đúng, phân biệt được SAST vs DAST |
| **TỔNG** | **100** | |

### Xếp loại:
- **Giỏi (≥85):** Đủ 3 tools + CI script tự động + bài tập mở rộng
- **Khá (70-84):** Đủ 3 tools, có báo cáo, CI script chạy được
- **TB (50-69):** Chạy được 2/3 tools, còn lỗi
- **Yếu (<50):** Chưa chạy được sample API
