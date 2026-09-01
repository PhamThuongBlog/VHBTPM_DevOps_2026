# Lab 10 — Capstone Project: Khắc phục sự cố & Giải pháp

> Tài liệu tổng kết toàn bộ vấn đề gặp phải khi chạy Jenkins pipeline và cách khắc phục,
> từ lúc build bị lỗi cho đến khi cả 14 stage chạy xanh và xem được kết quả monitoring.

---

## 1. Tổng quan

- **Ứng dụng:** Spring Boot `student-manager` (Java 17, H2, Actuator + Prometheus).
- **Pipeline:** Jenkins declarative, 14 stage / 6 phase (Plan → Code → Build → Test → SAST → Package → Nexus → Docker Build → Docker Push → Deploy → DAST → API Test → Monitor → Feedback).
- **Repo code:** `https://github.com/PhamThuongBlog/student-manager.git` (branch `main`).
- **Hạ tầng (docker-compose):** Jenkins, Nexus, SonarQube, Elasticsearch, Logstash, Kibana, Prometheus, Grafana — network `configs_devops-net`.
- **Trạng thái cuối:** ✅ 14/14 stage xanh; app deploy healthy; artifact lên Nexus; image lên Docker Hub; log lên ELK; metrics lên Prometheus/Grafana; FEEDBACK tự tạo GitHub issues.

---

## 2. Bảng tóm tắt vấn đề → giải pháp

| # | Vấn đề (lỗi) | Nguyên nhân | Giải pháp |
|---|---|---|---|
| 1 | `Tool type "jdk" does not have an install of "JDK21"` | Jenkins chỉ cấu hình JDK17 | Đổi `jdk 'JDK21'` → `jdk 'JDK17'` |
| 2 | `No test report files were found` | GitHub `main` thiếu `src/test/` | Push test + Dockerfile + postman + scripts + `.gitignore` |
| 3 | `No plugin found for prefix 'sonar'` | Thiếu sonar-maven-plugin | Thêm `sonar-maven-plugin` vào `pom.xml` |
| 4 | SonarQube Quality Gate fail | Coverage 0% + code smell field injection | Báo coverage (jacoco XML) + `@Autowired`→constructor injection |
| 5 | `docker: not found` (stage 8) | Image Jenkins không có Docker CLI | Cài Docker CLI static vào container |
| 6 | `permission denied` trên `/var/run/docker.sock` | Socket `root:root` 660, user jenkins không truy cập | `usermod -aG root jenkins` + `group_add: ["0"]` |
| 7 | `docker push` bị denied | Container Jenkins chưa login Docker Hub | `docker login` cho `phamthuongdocker` |
| 8 | `--network capstone_devops-net` sai | Tên mạng thật là `configs_devops-net` | Sửa network trong Jenkinsfile |
| 9 | Health check `localhost:8082` không tới app | `localhost` = chính container Jenkins | Đổi sang `student-manager:8082` (container name) |
| 10 | Nexus repo `maven-releases_Lab10` (chữ hoa) 404 | Tên repo thật `maven-releases_lab10` (thường) | Sửa tên + `writePolicy: ALLOW` + settings.xml auth |
| 11 | `DOCKER_USER='YOUR_DOCKER_USERNAME'` | Placeholder chưa thay | Đổi `phamthuongdocker` |
| 12 | `owasp/zap2docker-stable` pull fail | Image đã bị xóa khỏi Docker Hub | Đổi sang `zaproxy/zap-stable` |
| 13 | ZAP `AccessDeniedException /zap/wrk/zap-report.html` | Mount sai host path + quyền ghi | Mount đúng host path volume + `chmod 777 reports` |
| 14 | `newman: not found` (stage 12) | Image Jenkins không có Node/Newman | Cài Node.js + Newman vào `Dockerfile.jenkins` |
| 15 | Newman API test `errored` (ECONNREFUSED) | Postman trỏ `localhost` | Đổi `localhost`→`student-manager` (cả `raw` lẫn `host`) |
| 16 | ELK index rỗng (log không vào) | JSON escape thủ công bị hỏng | Dùng `node JSON.stringify` để ship log |
| 17 | FEEDBACK chỉ echo, không tự sinh issue | Stage 14 chưa tự động hóa | Viết stage 14 auto-create GitHub issues (REST API) |
| 18 | Docker fixes mất khi recreate container | Fix thủ công nằm trong writable layer | Tạo `Dockerfile.jenkins` + `group_add` (vĩnh viễn) |
| 19 | Grafana dashboard trống, Kibana không xem log | Chưa cấu hình | Tạo Grafana dashboard+panel+alert, Kibana index pattern+dashboard |

---

## 3. Chi tiết các vấn đề & giải pháp

### 3.1 Mã nguồn (code)
- **Thiếu test/Dockerfile/postman/scripts trên GitHub:** branch `main` chưa có các file cần thiết.
  → Push đầy đủ + thêm `.gitignore` (loại `target/`, `*.jar`, report) + bỏ `target/` khỏi git.
- **`@Autowired` field injection** gây code smell (SonarQube maintainability):
  → Chuyển sang constructor injection trong `StudentController` và `StudentManagerApplication`.

### 3.2 CI — Build/Test/SonarQube
- **`mvn sonar:sonar` lỗi prefix:** thêm vào `pom.xml`:
  ```xml
  <plugin>
    <groupId>org.sonarsource.scanner.maven</groupId>
    <artifactId>sonar-maven-plugin</artifactId>
    <version>3.11.0.3922</version>
  </plugin>
  ```
- **Coverage 0% → QG fail:** truyền `-Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml`
  và báo host/token tường minh `-Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN`.
  Kết quả: coverage ~85.9%, maintainability/reliability/security rating A.

### 3.3 Release — Nexus
- Repo deploy là `maven-releases_lab10` (thường), version policy RELEASE → pom đổi `1.0.0` (không SNAPSHOT).
- `writePolicy` đổi `ALLOW` (cho phép redeploy).
- Auth: `withCredentials([usernamePassword('nexus-credentials')])` → sinh `nexus-settings.xml` → `mvn deploy -s`.

### 3.4 CD — Docker Build/Push/Deploy
- **Docker CLI + socket:** `configs/Dockerfile.jenkins` cài Docker CLI static + `usermod -aG root jenkins`;
  `docker-compose-infra.yml` thêm `build` + `group_add: ["0"]`.
- **Docker Hub:** `docker login` cho `phamthuongdocker` (PAT lưu trong volume `jenkins_home`).
- **Network:** `configs_devops-net` (tên thật của mạng, do compose project tên `configs`).
- **Health check:** dùng `curl http://student-manager:8082/api/students/health` (container name, cùng mạng).

### 3.5 Operate — DAST (ZAP) & API Test (Newman)
- **ZAP image:** `owasp/zap2docker-stable` đã bị xóa → dùng `zaproxy/zap-stable`.
- **ZAP report:** docker-in-docker nên mount phải dùng host path:
  `JH_HOME=$(docker inspect capstone-jenkins --format '{{range .Mounts}}{{if eq .Destination "/var/jenkins_home"}}{{.Source}}{{end}}{{end}}')`
  rồi mount `${JH_HOME}/workspace/Lab10/reports` + `chmod 777 reports`.
- **Newman:** cài Node.js 20.18.0 + Newman 6.x trong `Dockerfile.jenkins`.
- **Postman URL:** Postman v2.1 lưu URL ở cả `raw` lẫn `host`/`port` (Newman dùng `host`);
  đổi cả 2 thành `student-manager`.

### 3.6 Monitor — ELK & Prometheus
- **Log shipping lỗi JSON:** dùng `node -e 'JSON.stringify({log:..., "@timestamp":...})'` thay vì nối chuỗi thủ công.
- **Grafana:** datasource Prometheus + dashboard "Dashboard for Lab 10" (4 panel) + 2 alert rule (app down, heap > 80%).
- **Kibana:** index pattern `student-manager-logs` + dashboard "Student Manager Logs" (log count + ERROR count).

### 3.7 Feedback — tự động tạo issue
- Stage 14 đọc kết quả (Newman JSON, Prometheus `up`, ES ERROR count, ZAP JSON) → nếu có vấn đề
  → POST GitHub API tạo issue (label `automated`), dùng credential `github-token` (fine-grained PAT, quyền Issues: Read/write).

---

## 4. Cấu hình hạ tầng (Jenkins + tools)

- **Jenkins:** admin/admin123. Tools: JDK17 (`/opt/java/openjdk`), Maven M3 (3.9.16).
  Credentials: `sonarqube-token`, `nexus-credentials`, `github-token`. Global env `DOCKER_USER=phamthuongdocker`.
- **Nexus:** admin/nexus123, repo `maven-releases_lab10` (writePolicy ALLOW).
- **SonarQube:** admin/sonar123, token `sqa_...`, webhook `jenkins` → `http://capstone-jenkins:8080/sonarqube-webhook/`.
- **Grafana:** admin/admin123, datasource `prometheus` (uid `cfwxch46qq5fke`).
- **Kibana/ES/Prometheus:** không auth. Index `student-manager-logs`.

### File infra đã sửa
- `configs/docker-compose-infra.yml` — thêm `build` + `group_add` cho jenkins.
- `configs/Dockerfile.jenkins` — image Jenkins custom (Docker CLI + Node/Newman + root group).

---

## 5. Kết quả cuối

- ✅ 14/14 stage xanh (`Finished: SUCCESS`).
- ✅ Artifacts: `target/student-manager-1.0.0.jar`, `newman-report.json`, `reports/zap-report.html`, `reports/zap-report.json`.
- ✅ App `student-manager` healthy tại `http://localhost:8082/api/students/health`.
- ✅ Monitoring: Grafana (metrics + alert), Kibana (log), Prometheus (PromQL), Elasticsearch (query).
- ✅ FEEDBACK tự mở GitHub issue khi có sự cố.
