# Lab 2: Thiết lập Môi trường DevOps & Áp dụng Nguyên tắc CALMS

> **Hướng dẫn chi tiết từng bước — Thời lượng: 75 phút**
> **Bài 2 — DevOps và các Nguyên tắc Cốt lõi**

---

## Mục tiêu

Sau lab này, bạn sẽ:

1. Cài đặt **DevOps Toolchain**: VS Code + Git + Docker Desktop
2. Hiểu **5 nguyên tắc CALMS của DevOps** qua thực hành
3. Viết **automation script** đầu tiên (nguyên tắc Automation)
4. Sử dụng **Docker** để loại bỏ "It works on my machine" (nguyên tắc Lean)
5. Vẽ **DevOps Toolchain Map** — biết tool nào cho giai đoạn nào

---

## Yêu cầu

| Thành phần | Yêu cầu | Ghi chú |
|------------|---------|---------|
| OS | Windows 10+/macOS/Linux | |
| RAM | ≥ 8GB | Docker cần ~2GB |
| Internet | Có | Để tải Docker images |
| **VS Code** | Bản mới nhất | [Tải tại đây](https://code.visualstudio.com/) |
| **Git** | ≥ 2.40 | Cần cài từ khi thực hiện Lab 1 |
| **Docker Desktop** | ≥ 24.x | [Tải tại đây](https://www.docker.com/products/docker-desktop/) |
| **Tài khoản GitHub** | Có | Đã tạo ở Lab 1 |

---

## KIẾN THỨC NỀN — DevOps & CALMS

### DevOps là gì?

> DevOps là sự kết hợp giữa **con người (people)**, **quy trình (process)** và **công cụ (tools)** để tăng khả năng cung cấp giá trị cho khách hàng nhanh hơn, ổn định hơn.

### CALMS — 5 Trụ cột của DevOps

| Trụ cột | Tiếng Việt | Ý nghĩa | Ví dụ |
|---------|-----------|---------|-------|
| **C**ulture | Văn hóa | Phá bỏ silo Dev vs Ops, cùng chịu trách nhiệm | Dev viết code + Ops viết infra = 1 team |
| **A**utomation | Tự động hóa | Tự động mọi thứ: build, test, deploy, monitor | CI/CD pipeline (GitHub Actions, Jenkins) |
| **L**ean | Tinh gọn | Loại bỏ lãng phí, tối ưu flow | Docker thay vì cài thủ công trên 10 server |
| **M**easurement | Đo lường | Đo lường mọi thứ để cải tiến | Build time, deploy frequency, error rate |
| **S**haring | Chia sẻ | Chia sẻ kiến thức, code, trách nhiệm | Code review, post-mortem, knowledge base |

### DevOps Toolchain (Chuỗi Công cụ)

```
PLAN ──▶ CODE ──▶ BUILD ──▶ TEST ──▶ RELEASE ──▶ DEPLOY ──▶ OPERATE ──▶ MONITOR
 │         │        │         │          │           │          │           │
GitHub    Git      Maven     JUnit     Jenkins     Docker     Ansible    Prometheus
Projects  VS Code  Gradle    Postman   Nexus       K8s        Terraform  Grafana
Jira      GitHub   npm       SonarQube Artifactory Helm       AWS        ELK
```

---

## BƯỚC 1: Cài đặt DevOps Toolchain Cơ bản (20 phút)

> **Mục tiêu CALMS:** Thiết lập nền tảng công cụ để tự động hóa (Automation) và tinh gọn (Lean)

### 1.1 VS Code — IDE cho DevOps

```bash
# Kiểm tra đã cài chưa
code --version
```

Nếu chưa cài: https://code.visualstudio.com/

**Cài đặt Extensions DevOps cần thiết:**

Mở VS Code → Extensions (Ctrl+Shift+X) → cài:
- **GitLens** — Git supercharged (xem blame, history ngay trong editor)
- **Docker** — Quản lý Docker containers/images ngay trong VS Code
- **YAML** — Syntax highlighting cho GitHub Actions, Docker Compose
- **Prettier** — Format code tự động
- **Markdown Preview** — Xem trước file .md

### 1.2 Git — Version Control

```bash
git --version

# Cấu hình nếu chưa làm
git config --global user.name "YOUR_NAME"
git config --global user.email "YOUR_EMAIL"
```

### 1.3 Docker Desktop — "It works on my machine" → "It works EVERYWHERE"

```bash
# Kiểm tra cài đặt
docker --version
docker compose version

# Kiểm tra Docker đang chạy
docker info
```

Nếu chưa cài: https://www.docker.com/products/docker-desktop/

**Sau khi cài:** Mở Docker Desktop → Settings → Resources:
- Memory: 4GB (tối thiểu)
- CPUs: 2

### 1.4 Verify Toolchain

Chạy script kiểm tra:

```bash
echo "=== DEVOPS TOOLCHAIN CHECK ==="
echo ""

echo -n "VS Code:  "; code --version 2>/dev/null | head -1 || echo "❌ Not installed"
echo -n "Git:      "; git --version 2>/dev/null || echo "❌ Not installed"
echo -n "Docker:   "; docker --version 2>/dev/null || echo "❌ Not installed"
echo -n "Node.js:  "; node --version 2>/dev/null || echo "⚠️  Optional"

echo ""
echo " Toolchain ready for DevOps!"
```
**Lưu ý:**
- Tạo file kịch bản tại đường dẫn Lab2: ví dụ: "devops-check.sh" với nội dung như trên
- Mở Bash và cd đến thư mục chứa file trên và chạy lệnh: bash devops-check.sh


✅ **Tiêu chí chấm 1:** Cả 3 công cụ (VS Code, Git, Docker) đều hiển thị version?

---

## BƯỚC 2: Automation — Script Tự động hóa Đầu tiên (15 phút)

> **Mục tiêu CALMS:** Hiểu nguyên tắc **Automation** — biến công việc thủ công thành code chạy tự động

### 2.1 Bài toán

Bạn là developer trong team 5 người. Mỗi người tự cài đặt môi trường dev (Node.js, dependencies). Mỗi lần có người mới join → mất 2 giờ hướng dẫn cài đặt. Làm sao để giảm xuống còn 2 phút?

→ **Giải pháp:** bạn tự điền giải pháp vào đây!

>  **Bài học DevOps #1:** Bất cứ việc gì làm thủ công ≥ 2 lần → **HÃY VIẾT SCRIPT TỰ ĐỘNG HÓA!**

✅ **Tiêu chí chấm 2:** Đề xuất được giải pháp tự động hóa?

---

## BƯỚC 3: Lean — Tối ưu với Docker (15 phút)

>  **Mục tiêu CALMS:** Hiểu nguyên tắc **Lean** — loại bỏ lãng phí "It works on my machine"

### 3.1 Bài toán

Bạn code ứng dụng Node.js trên máy Windows. Đồng đội dùng macOS. Server deploy dùng Linux. Ứng dụng chạy trên máy bạn nhưng lỗi trên máy đồng đội vì khác phiên bản Node.js. Đây gọi là vấn đề **"It works on my machine"** — một trong những lãng phí lớn nhất!

**Giải pháp:** Dùng Docker — đóng gói ứng dụng + môi trường thành 1 container.

### 3.2 Viết Dockerfile

Tạo file `Dockerfile`:

```dockerfile
# DevOps Lab 2 — Docker Demo
# Sử dụng Node.js official image
FROM node:18-alpine

# Thiết lập thư mục làm việc
WORKDIR /app

# Copy package.json trước (tận dụng Docker cache)
COPY package.json .

# Cài đặt dependencies
RUN npm install

# Copy source code
COPY . .

# Expose port
EXPOSE 3000

# Lệnh chạy ứng dụng
CMD ["node", "server.js"]
```

Tạo file `server.js` đơn giản:

```javascript
const http = require('http');

const server = http.createServer((req, res) => {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
        message: 'Hello from Docker!',
        lab: 'DevOps Lab 2 — Lean Principle',
        timestamp: new Date().toISOString(),
        node_version: process.version,
        platform: process.platform,
    }));
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(` Server running at http://localhost:${PORT}`);
    console.log(`Environment: Node.js ${process.version} on ${process.platform}`);
});
```

Tạo file `package.json`:

```json
{
  "name": "devops-lab2-docker",
  "version": "1.0.0",
  "description": "DevOps Lab 2 — Docker Lean Demo",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  }
}
```

### 3.3 Build & Chạy Docker
Thực thi các lệnh sau ở PowerShell:
```bash
# Build Docker image
docker build -t devops-lab2-app .

# Chạy container
docker run -d -p 3000:3000 --name lab2-app devops-lab2-app

# Kiểm tra
curl http://localhost:3000
```

**Kết quả mong đợi:**
```json
{
  "message": "Hello from Docker!",
  "lab": "DevOps Lab 2 — Lean Principle",
  "timestamp": "2026-07-03T...",
  "node_version": "v18.x.x",
  "platform": "linux"
}
```

### 3.4 So sánh — Nguyên tắc Lean

| Không có Docker (Lãng phí) | Có Docker (Lean) |
|---------------------------|------------------|
| Cài Node.js thủ công trên mỗi máy | Node.js có sẵn trong image |
| "Trên máy tôi chạy được mà!" | Container giống hệt nhau mọi nơi |
| Dev: Windows, Ops: Linux → conflict | Docker chạy Linux container trên mọi OS |
| Mất 30 phút setup môi trường mới | `docker run` → 5 giây |
| Version Node.js khác nhau giữa các máy | Version cố định trong Dockerfile |

>  **Bài học DevOps #2:** Docker loại bỏ lãng phí "It works on my machine" → Môi trường **giống hệt** từ dev → test → production.

### 3.5 Dọn dẹp Container

```bash
docker stop lab2-app && docker rm lab2-app
```

 **Tiêu chí chấm 3:** `curl localhost:3000` trả về JSON? Docker container đang chạy?

---

## BƯỚC 4: DevOps Toolchain Map + Tổng kết (15 phút)

>  **Mục tiêu CALMS:** **Measurement** (đo lường tools) + **Sharing** (chia sẻ kiến thức)

### 4.1 Vẽ DevOps Toolchain Map

Dựa trên những gì đã học ở Bài 1-2, hãy vẽ sơ đồ DevOps toolchain (công cụ cho từng giai đoạn):

```
┌─────────────────────────────────────────────────────────────────────┐
│                        DEVOPS TOOLCHAIN                             │
│                                                                     │
│  PLAN       CODE       BUILD      TEST       DEPLOY     MONITOR    │
│  ────       ────       ─────      ────       ──────     ───────    │
│  GitHub     Git        Maven      JUnit      Docker     Prometheus │
│  Projects   VS Code    Gradle     Postman    K8s        Grafana    │
│  Jira       GitHub     npm        SonarQube  Terraform  ELK Stack  │
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    CI/CD ORCHESTRATOR                        │   │
│  │          Jenkins / GitHub Actions / GitLab CI               │   │
│  └─────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Điền vào Bảng — Công cụ DevOps đã Học

| Giai đoạn | Công cụ | Đã dùng ở lab nào? | Mục đích |
|-----------|---------|:---:|----------|
| **Plan** | GitHub Projects | — | Quản lý task, roadmap |
| **Code** | Git + GitHub | Lab 1, 5 | Quản lý mã nguồn |
| **Code** | VS Code | Lab 2 | IDE |
| **Build** | Maven | Lab 7 | Build Java project |
| **Test** | Postman/Newman | Lab 6 | Kiểm thử API |
| **Test** | SonarQube | Lab 6, 7 | Phân tích mã nguồn tĩnh |
| **Test** | OWASP ZAP | Lab 6 | Kiểm thử bảo mật |
| **Deploy** | Docker | Lab 2, 7, 8 | Container hóa ứng dụng |
| **Deploy** | Terraform | Lab 3 | Infrastructure as Code |
| **Deploy** | AWS | Lab 3 | Cloud infrastructure |
| **CI/CD** | GitHub Actions | Lab 1 | Tự động deploy web |
| **CI/CD** | Jenkins | Lab 7 | CI/CD pipeline |
| **Artifact** | Nexus | Lab 7 | Quản lý artifact |

### 4.3 Tổng kết — CALMS trong Thực tế

| Nguyên tắc | Bạn đã làm gì? | Lab nào? |
|-----------|---------------|:---:|
| **C**ulture | Team workflow với Git Flow + Code Review | Lab 5 |
| **A**utomation | CI/CD pipeline tự động deploy website | Lab 1 |
| **A**utomation | Automation script setup môi trường | Lab 2 |
| **L**ean | Docker — môi trường nhất quán mọi nơi | Lab 2 |
| **L**ean | Infrastructure as Code — không cấu hình thủ công | Lab 3 |
| **M**easurement | Test reports (Newman, SonarQube metrics) | Lab 6 |
| **M**easurement | Pipeline duration, success rate | Lab 7 |
| **S**haring | Code Review trên GitHub | Lab 5 |
| **S**haring | Toolchain map — chia sẻ kiến thức | Lab 2 |

 **Tiêu chí chấm 4:** Đã vẽ toolchain map + điền bảng công cụ + điền bảng CALMS?

---

## BƯỚC 5: CALMS Self-Assessment (10 phút)

### 5.1 Tự Đánh giá DevOps Maturity

Chấm điểm team/ cá nhân bạn theo thang 1-5:

| Nguyên tắc | 1 (Yếu) | 3 (Trung bình) | 5 (Xuất sắc) | Điểm của bạn |
|-----------|---------|---------------|-------------|:---:|
| **C**ulture | Dev vs Ops đổ lỗi cho nhau | Dev với Ops ngồi chung team | Mọi người cùng chịu trách nhiệm production | /5 |
| **A**utomation | Deploy thủ công 100% | Có CI/CD cho 1 số project | Toàn bộ pipeline tự động | /5 |
| **L**ean | Setup môi trường mất > 1 ngày | Có script, Docker 1 phần | 1 lệnh → môi trường sẵn sàng | /5 |
| **M**easurement | Không biết app có đang chạy không | Có monitoring cơ bản | Dashboard real-time + alert | /5 |
| **S**haring | Mỗi người tự biết, không document | Có wiki nội bộ | Code review + post-mortem + knowledge sharing | /5 |
| **TỔNG** | | | | **/25** |

### 5.2 Kế hoạch Cải thiện

Dựa trên điểm số, viết ra 3 hành động cụ thể để cải thiện DevOps maturity:

1. ________________________________________________
2. ________________________________________________
3. ________________________________________________

 **Tiêu chí chấm 5:** Đã tự đánh giá CALMS + viết 3 hành động cải thiện?

---

## TROUBLESHOOTING

| # | Lỗi | Cách khắc phục |
|---|------|---------------|
| 1 | Docker không chạy được | Mở Docker Desktop, đợi "Engine running" (màu xanh) |
| 2 | `docker build` báo "permission denied" | Linux: thêm user vào group docker `sudo usermod -aG docker $USER` |
| 3 | Port 3000 already in use | Đổi port trong `server.js` hoặc kill process đang dùng port |
| 4 | `code` command not found | VS Code → Command Palette → "Shell Command: Install 'code' in PATH" |
| 5 | Docker pull quá chậm | Dùng Docker mirror hoặc đợi (chỉ cần pull lần đầu) |
| 6 | Script `.sh` không chạy trên Windows | Dùng Git Bash hoặc WSL, hoặc chạy file `.ps1` (PowerShell) |

---

## BÀI TẬP MỞ RỘNG

### 🟢 Cơ bản
1. **Thêm health check vào Dockerfile:** `HEALTHCHECK --interval=30s CMD curl -f http://localhost:3000 || exit 1`
2. **Thêm Docker Compose:** Tạo `docker-compose.yml` chạy app + database

### 🟡 Trung bình
3. **CI/CD cho Docker app:** Tạo GitHub Actions pipeline build Docker image + push lên Docker Hub
4. **Multi-stage Docker build:** Tối ưu Docker image size (giảm từ 200MB → 50MB)

### 🔴 Nâng cao
5. **DevSecOps:** Thêm Snyk/Trivy scan vào automation script để quét lỗ hổng dependencies
6. **Infrastructure as Code:** Dùng Terraform để provision môi trường dev tự động

---

## TIÊU CHÍ CHẤM ĐIỂM - TỔNG KẾT

| # | Tiêu chí | Điểm | Cách đánh giá |
|---|----------|:----:|--------------|
| 1 | **Toolchain** — VS Code + Git + Docker cài đặt OK | 20% | `code --version`, `git --version`, `docker --version` |
| 2 | **Automation Script** — chạy thành công | 25% | Script tạo đủ cấu trúc dự án |
| 3 | **Docker App** — build + chạy container | 25% | `curl localhost:3000` trả về JSON |
| 4 | **Toolchain Map** — vẽ đúng các giai đoạn + công cụ | 15% | Sơ đồ có ≥ 6 giai đoạn, ≥ 10 công cụ |
| 5 | **CALMS Assessment** — tự đánh giá + kế hoạch | 15% | Bảng đánh giá + 3 hành động |
| **TỔNG** | | **100%** | |

### Cách Nộp bài

```
Lab2_HoTen_MSSV.zip
├── setup-dev-env.sh (hoặc .ps1)    ← Automation script
├── Dockerfile                       ← Docker configuration
├── server.js                        ← Node.js app
├── screenshots/
│   ├── 01-toolchain-check.png       ← Toolchain versions
│   ├── 02-automation-script.png     ← Script chạy thành công
│   ├── 03-docker-build.png          ← docker build output
│   ├── 04-docker-run-curl.png       ← curl localhost:3000
│   ├── 05-toolchain-map.png         ← DevOps toolchain map
│   └── 06-calms-assessment.png      ← CALMS bảng đánh giá
└── ho_ten_mssv.txt
```

---

> 🎯 **Lab này tương ứng với:** CDR 2.1 + 2.2 + 2.3
>
> 📅 **Cập nhật:** 2026-07-03
