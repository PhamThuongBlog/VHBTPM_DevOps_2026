# 🏆 CAPSTONE PROJECT: DevOps End-to-End Pipeline

## Student Manager Application — Full DevOps Lifecycle

> **Thời lượng:** 180 phút (3 tiết) | **Hình thức:** Nhóm 2-3 người
> **Tích hợp:** Bài 1→9 | **Độ khó:** ⭐⭐⭐⭐⭐ (Tổng hợp)

---

## 📋 Mục lục
1. [Tổng quan Case Study](#1-tổng-quan)
2. [Kiến trúc Hệ thống & Pipeline](#2-kiến-trúc)
3. [Chuẩn bị Môi trường](#3-chuẩn-bị)
4. [GIAI ĐOẠN 1: PLAN & CODE](#4-plan--code)
5. [GIAI ĐOẠN 2: CI — Build, Test, Static Analysis](#5-ci-pipeline)
6. [GIAI ĐOẠN 3: RELEASE — Package & Publish](#6-release)
7. [GIAI ĐOẠN 4: CD — Docker Build & Deploy](#7-cd-pipeline)
8. [GIAI ĐOẠN 5: OPERATE — Security Test & Monitor](#8-operate)
9. [GIAI ĐOẠN 6: FEEDBACK — Từ Monitor về Plan](#9-feedback)
10. [Tổng kết & Nộp bài](#10-tổng-kết)
11. [Mở rộng — Triển khai trên AWS EC2 thật](#11-mở-rộng--triển-khai-trên-aws-ec2-thật)

---

## 1. TỔNG QUAN CASE STUDY

### Bối cảnh

Bạn là **DevOps Engineer** trong team phát triển **Student Manager** — ứng dụng quản lý sinh viên. Nhiệm vụ: xây dựng **toàn bộ DevOps pipeline** để tự động hóa từ lúc viết code đến lúc ứng dụng chạy trên production.

### Ứng dụng

**Student Manager API** — REST API quản lý sinh viên:
- **Tech stack:** Java 17 + Spring Boot 3 + Maven
- **Endpoints:** CRUD students, search, health check
- **Database:** H2 (in-memory, không cần cài đặt)
- **Port:** 8080

### Công cụ DevOps sử dụng (ánh xạ bài học)

| Giai đoạn | Công cụ | Bài học |
|-----------|---------|:---:|
| **Plan** | GitHub Projects, Issues | Bài 1 |
| **Code** | Git, GitHub, Git Flow | Bài 5 |
| **Build** | Maven | Bài 7 |
| **Test** | JUnit 5, Postman/Newman | Bài 6, 7 |
| **Static Analysis** | SonarQube (SAST) | Bài 6, 7 |
| **Package** | Maven → .jar | Bài 7 |
| **Artifact Repo** | Nexus Repository | Bài 7 |
| **Container Build** | Docker, Dockerfile | Bài 8 |
| **Registry Push** | Docker Hub | Bài 8 |
| **Deploy** | Docker Compose | Bài 8 |
| **Security Test** | OWASP ZAP (DAST) | Bài 6 |
| **Orchestrator** | **Jenkins** (CI+CD pipeline) | Bài 7, 8 |
| **Trigger** | GitHub Actions → Jenkins | Bài 7, 8 |
| **Monitor** | ELK (Elasticsearch + Logstash + Kibana) + Prometheus + Grafana | Bài 2, 9 |

---

## 2. KIẾN TRÚC HỆ THỐNG & PIPELINE

### Kiến trúc Triển khai

<p align="center">
  <img src="images_lab10/1_tongquan.png" alt="Kiến trúc triển khai" width="1000">
</p>

### DevOps Pipeline End-to-End

<p align="center">
  <img src="images_lab10/2_devops_pipeline.png" alt="DevOps Pipeline" width="1000">
</p>

---

## 3. CHUẨN BỊ MÔI TRƯỜNG

### Yêu cầu

| Công cụ | Version | Kiểm tra |
|---------|---------|----------|
| Docker Desktop | ≥ 24.x | `docker --version` |
| Docker Compose | ≥ v2 | `docker compose version` |
| Git | ≥ 2.40 | `git --version` |
| JDK | ≥ 17 | `java --version` |
| Maven | ≥ 3.9 | `mvn --version` |
| Node.js | ≥ 18 | `node --version` |
| Postman | Latest | Desktop app |
| OWASP ZAP | ≥ 2.15 | Desktop app |
| GitHub Account | — | github.com |

### Khởi động Môi trường DevOps

```bash
# Tạo thư mục capstone
mkdir capstone-devops && cd capstone-devops
New-Item -ItemType Directory -Path configs, screenshots -Force
```
=> Lệnh trên tương đương với lệnh này (chạy trên Linux/ MacOS): 

```bash
mkdir -p configs screenshots
```

**Tạo `configs/docker-compose-infra.yml`** (Jenkins + Nexus + SonarQube + ELK (Elasticsearch + Logstash + Kibana) + Prometheus + Grafana):
Chạy lệnh:

```bash
New-Item -ItemType File -Path "configs\docker-compose-infra.yml" -Force
```

**Nội dung file:**

```yaml
# ============================================================================
#  docker-compose-infra.yml — Infrastructure DevOps + Observability Stack
#
#  CI/CD tools     : Jenkins, Nexus, SonarQube
#  Monitoring stack: ELK (Elasticsearch + Logstash + Kibana) + Prometheus + Grafana
#  Network         : devops-net (shared với Student Manager app)
# ============================================================================
version: '3.8'

services:

  # ---------------- CI/CD Orchestration ----------------

  jenkins:
    image: jenkins/jenkins:lts-jdk17
    container_name: capstone-jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
      - /var/run/docker.sock:/var/run/docker.sock
    networks:
      - devops-net

  nexus:
    image: sonatype/nexus3:latest
    container_name: capstone-nexus
    ports:
      - "8081:8081"
    volumes:
      - nexus_data:/nexus-data
    networks:
      - devops-net

  sonarqube:
    image: sonarqube:lts-community
    container_name: capstone-sonarqube
    ports:
      - "9000:9000"
    environment:
      - SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true
    volumes:
      - sonar_data:/opt/sonarqube/data
    networks:
      - devops-net

  # ---------------- ELK Stack (Log Monitoring) ----------------

  # Lưu trữ & truy vấn log tập trung (index: student-manager-logs-*)
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:7.17.22
    container_name: capstone-elasticsearch
    ports:
      - "9200:9200"
    environment:
      - discovery.type=single-node
      - xpack.security.enabled=false
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
    volumes:
      - es_data:/usr/share/elasticsearch/data
    networks:
      - devops-net

  # Nhận log (beats/http) → parse → đẩy vào Elasticsearch
  logstash:
    image: docker.elastic.co/logstash/logstash:7.17.22
    container_name: capstone-logstash
    ports:
      - "9600:9600"       # API status
    environment:
      - xpack.monitoring.enabled=false
    # Pipeline mặc định: nhận HTTP JSON → ghi vào Elasticsearch
    command: >
      logstash -e 'input { http { port => 9600 } }
                    filter { json { source => "message" } }
                    output { elasticsearch { hosts => ["http://elasticsearch:9200"] index => "student-manager-logs" } }'
    depends_on:
      - elasticsearch
    networks:
      - devops-net

  # Dashboard trực quan hoá log
  kibana:
    image: docker.elastic.co/kibana/kibana:7.17.22
    container_name: capstone-kibana
    ports:
      - "5601:5601"
    environment:
      - ELASTICSEARCH_HOSTS=http://elasticsearch:9200
    depends_on:
      - elasticsearch
    networks:
      - devops-net

  # ---------------- Metrics Stack (Prometheus + Grafana) ----------------

  # Thu thập metrics (Spring Boot Actuator /micrometer → /actuator/prometheus)
  prometheus:
    image: prom/prometheus:latest
    container_name: capstone-prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
    networks:
      - devops-net

  # Dashboard trực quan hoá metrics
  grafana:
    image: grafana/grafana:latest
    container_name: capstone-grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana
    depends_on:
      - prometheus
    networks:
      - devops-net

volumes:
  jenkins_home:
  nexus_data:
  sonar_data:
  es_data:
  grafana_data:

networks:
  devops-net:
    driver: bridge
```

```bash
# Khởi động infrastructure
docker compose -f configs/docker-compose-infra.yml up -d

# Đợi ~2 phút, lấy passwords
docker exec capstone-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
docker exec capstone-nexus cat /nexus-data/admin.password
```

**Lưu ý quan trọng trước khi chạy:** 

    Chuẩn bị file cấu hình Prometheus:
    Vì trong file docker-compose-infra.yml, service prometheus có mount file cấu hình:
    ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml:ro

    Do đó, ta bắt buộc phải tạo sẵn file prometheus.yml tại thư mục ./prometheus/ trên máy host trước khi chạy lệnh. Nếu không có file này, Docker sẽ tự tạo một thư mục trống tên prometheus.yml và làm container Prometheus bị crash ngay khi khởi động.

   => Xem / download file này tại:     /configs/prometheus/prometheus.yml
   

✅ **Checkpoint 0:** Các containers Up? Jenkins(:8080), Nexus(:8081), SonarQube(:9000) và các container khác có truy cập được?

Bảng tổng hợp URL truy cập vào giao diện Web (UI) và API của tất cả các container trong hệ thống DevOps & Observability của bạn:

| Dịch vụ / Container | Tên Container (`container_name`) | Port Host | Đường dẫn URL | Tài khoản / Mật khẩu mặc định |
| :--- | :--- | :--- | :--- | :--- |
| **Jenkins** | `capstone-jenkins` | `8080` | `http://localhost:8080` | Mật khẩu khởi tạo: Lấy qua lệnh `docker exec capstone-jenkins cat /var/jenkins_home/secrets/initialAdminPassword` |
| **Nexus Repository** | `capstone-nexus` | `8081` | `http://localhost:8081` | User: `admin`<br>Mật khẩu: Lấy qua lệnh `docker exec capstone-nexus cat /nexus-data/admin.password` |
| **SonarQube** | `capstone-sonarqube` | `9000` | `http://localhost:9000` | User: `admin`<br>Password: `admin` *(yêu cầu đổi ở lần đăng nhập đầu)* |
| **Grafana** | `capstone-grafana` | `3000` | `http://localhost:3000` | User: `admin`<br>Password: `admin` *(khai báo trong `.yml`)* |
| **Prometheus** | `capstone-prometheus` | `9090` | `http://localhost:9090` | Không yêu cầu đăng nhập |
| **Kibana** | `capstone-kibana` | `5601` | `http://localhost:5601` | Không yêu cầu đăng nhập |
| **Elasticsearch** | `capstone-elasticsearch` | `9200` | `http://localhost:9200` | REST API (Không yêu cầu đăng nhập) |
| **Logstash** | `capstone-logstash` | `9600` | `http://localhost:9600` | API Status (Không yêu cầu đăng nhập) |
| **Student Manager App** | `student-manager` | `8080` *(hoặc gán port khác , ví dụ: 8082)* | `http://localhost:8082`<br>`http://localhost:8082/actuator/prometheus` | Endpoint ứng dụng chính và endpoint lấy metrics cho Prometheus |
| **OWASP ZAP (DAST)** | `zap` *(chạy tự động)* | `8090` | `http://localhost:8090` | ZAP Daemon API |

*Lưu ý: Thay `localhost` bằng **IP Public của máy chủ AWS EC2** nếu bạn đang truy cập từ máy tính cá nhân ở ngoài.*

---

## 4. GIAI ĐOẠN 1: PLAN & CODE

### 4.1 PLAN — Tạo GitHub Project Board (plan liên tục)

1. Vào GitHub → **Projects** → New project → Board (repo: `PhamThuongBlog/student-manager`)
2. Name: `Student Manager DevOps`
3. Tạo các issues:
   - `[STU-01] Create Student model & repository`
   - `[STU-02] Create REST API endpoints`
   - `[STU-03] Add unit tests`
   - `[STU-04] Add health check endpoint`
   - `[STU-05] Setup CI/CD pipeline`
4. Gán issues cho thành viên, set status

### 4.2 CODE — Tạo Project Spring Boot

```bash
# Tạo Spring Boot project với Maven
mkdir student-manager && cd student-manager
```

**Tạo `pom.xml`**:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.3.0</version>
    </parent>

    <groupId>com.devops.capstone</groupId>
    <artifactId>student-manager</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>
    <name>Student Manager — DevOps Capstone</name>

    <properties>
        <java.version>17</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>io.micrometer</groupId>
            <artifactId>micrometer-registry-prometheus</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
            <plugin>
                <groupId>org.jacoco</groupId>
                <artifactId>jacoco-maven-plugin</artifactId>
                <version>0.8.12</version>
                <executions>
                    <execution>
                        <goals><goal>prepare-agent</goal></goals>
                    </execution>
                    <execution>
                        <id>report</id>
                        <phase>test</phase>
                        <goals><goal>report</goal></goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</project>
```

**Tạo cấu trúc thư mục:**

```bash
New-Item -ItemType Directory -Path `
    "src/main/java/com/devops/capstone/model",
    "src/main/java/com/devops/capstone/repository",
    "src/main/java/com/devops/capstone/controller",
    "src/main/java/com/devops/capstone/config" `
    -Force
New-Item -ItemType Directory -Path ` "src/main/resources" ` -Force
New-Item -ItemType Directory -Path `
  "src/test/java/com/devops/capstone/controller",
  "src/test/java/com/devops/capstone/service" `
  -Force
```

**Note:** Nếu OS của máy là Linux/MacOS thì thực thi các lệnh tương đương sau:

```bash
mkdir -p src/main/java/com/devops/capstone/{model,repository,controller,config}
mkdir -p src/main/resources
mkdir -p src/test/java/com/devops/capstone/{controller,service}
```

### 4.3 Viết Code Ứng dụng

**`src/main/resources/application.properties`:**

```properties
server.port=8080
spring.application.name=student-manager
spring.datasource.url=jdbc:h2:mem:studentdb
spring.datasource.driverClassName=org.h2.Driver
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.h2.console.enabled=true
management.endpoints.web.exposure.include=health,info,metrics,prometheus
```

**`src/main/java/com/devops/capstone/model/Student.java`:**

Chạy lệnh tạo file:

```bash
New-Item -ItemType File -Path "src/main/java/com/devops/capstone/model/Student.java" -Force
```

**Nội dung file:**

```java
package com.devops.capstone.model;

import jakarta.persistence.*;

@Entity
@Table(name = "students")
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String studentId;

    @Column(nullable = false)
    private String name;

    private Integer age;
    private String grade;

    public Student() {}

    public Student(String studentId, String name, Integer age, String grade) {
        this.studentId = studentId;
        this.name = name;
        this.age = age;
        this.grade = grade;
    }

    // Getters và Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getStudentId() { return studentId; }
    public void setStudentId(String studentId) { this.studentId = studentId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public Integer getAge() { return age; }
    public void setAge(Integer age) { this.age = age; }
    public String getGrade() { return grade; }
    public void setGrade(String grade) { this.grade = grade; }
}
```

**`src/main/java/com/devops/capstone/repository/StudentRepository.java`:**

```java
package com.devops.capstone.repository;

import com.devops.capstone.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface StudentRepository extends JpaRepository<Student, Long> {
    List<Student> findByNameContainingIgnoreCase(String name);
    Student findByStudentId(String studentId);
}
```

**`src/main/java/com/devops/capstone/controller/StudentController.java`:**

```java
package com.devops.capstone.controller;

import com.devops.capstone.model.Student;
import com.devops.capstone.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/students")
public class StudentController {

    @Autowired
    private StudentRepository repository;

    // GET all students
    @GetMapping
    public ResponseEntity<Map<String, Object>> getAllStudents() {
        List<Student> students = repository.findAll();
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("success", true);
        response.put("data", students);
        response.put("total", students.size());
        response.put("service", "student-manager");
        response.put("version", "1.0.0");
        return ResponseEntity.ok(response);
    }

    // GET student by ID
    @GetMapping("/{id}")
    public ResponseEntity<Map<String, Object>> getStudent(@PathVariable Long id) {
        Optional<Student> student = repository.findById(id);
        Map<String, Object> response = new LinkedHashMap<>();
        if (student.isPresent()) {
            response.put("success", true);
            response.put("data", student.get());
        } else {
            response.put("success", false);
            response.put("message", "Student not found");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        return ResponseEntity.ok(response);
    }

    // POST create student
    @PostMapping
    public ResponseEntity<Map<String, Object>> createStudent(@RequestBody Student student) {
        Map<String, Object> response = new LinkedHashMap<>();
        if (student.getName() == null || student.getStudentId() == null) {
            response.put("success", false);
            response.put("message", "Name and studentId are required");
            return ResponseEntity.badRequest().body(response);
        }
        Student saved = repository.save(student);
        response.put("success", true);
        response.put("data", saved);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    // DELETE student
    @DeleteMapping("/{id}")
    public ResponseEntity<Map<String, Object>> deleteStudent(@PathVariable Long id) {
        Map<String, Object> response = new LinkedHashMap<>();
        if (!repository.existsById(id)) {
            response.put("success", false);
            response.put("message", "Student not found");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
        repository.deleteById(id);
        response.put("success", true);
        response.put("message", "Student deleted");
        return ResponseEntity.ok(response);
    }

    // GET search
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> search(@RequestParam String q) {
        List<Student> results = repository.findByNameContainingIgnoreCase(q);
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("success", true);
        response.put("data", results);
        response.put("keyword", q);
        response.put("count", results.size());
        return ResponseEntity.ok(response);
    }

    // GET health
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new LinkedHashMap<>();
        response.put("status", "UP");
        response.put("service", "student-manager");
        response.put("version", "1.0.0");
        response.put("timestamp", new Date().toString());
        return ResponseEntity.ok(response);
    }
}
```

**`src/main/java/com/devops/capstone/StudentManagerApplication.java`:**

```java
package com.devops.capstone;

import com.devops.capstone.model.Student;
import com.devops.capstone.repository.StudentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class StudentManagerApplication implements CommandLineRunner {

    @Autowired
    private StudentRepository repository;

    public static void main(String[] args) {
        SpringApplication.run(StudentManagerApplication.class, args);
    }

    @Override
    public void run(String... args) {
        // Seed data
        repository.save(new Student("SV001", "Nguyen Van A", 20, "K20"));
        repository.save(new Student("SV002", "Tran Thi B", 21, "K20"));
        repository.save(new Student("SV003", "Le Van C", 19, "K21"));
        System.out.println("Student Manager API ready — " + repository.count() + " students seeded");
    }
}
```

### 4.4 Test Local

```bash
mvn clean spring-boot:run
# Mở terminal khác:
curl.exe http://localhost:8080/api/students/1
curl.exe http://localhost:8080/api/students/health
```

**Lưu ý:**
Nếu xung đột cổng 8080 với Jenkins, thì thay đổi thành cổng khác (ví dụ:8082) ở file application.properties


### 4.5 Git Flow — Push lên GitHub

```bash
git init && git checkout -b main
git add . && git commit -m "feat: initial Student Manager API with CRUD + health"
git remote add origin https://github.com/PhamThuongBlog/student-manager.git
git push -u origin main

# Tạo develop branch
git checkout -b develop && git push origin develop
```

### 4.6 Trigger Tự động Jenkins bằng GitHub Actions (không webhook/ngrok)

Cơ chế: **GitHub Actions** chạy trên **self-hosted runner** (cùng máy Jenkins) → gọi Jenkins "remote build API" qua `http://localhost:8080`. Không cần public URL, không dùng webhook.

Tạo `.github/workflows/trigger-jenkins.yml` ở gốc repo (đã có sẵn trong bộ bài nộp):

```yaml
name: Trigger Jenkins DevOps Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
jobs:
  trigger-jenkins:
    runs-on: self-hosted          # runner chạy cùng máy Jenkins
    steps:
      - name: Trigger Jenkins build
        env:
          JENKINS_URL: ${{ secrets.JENKINS_URL }}
          JENKINS_TRIGGER_TOKEN: ${{ secrets.JENKINS_TRIGGER_TOKEN }}
        run: |
          curl -sS -X POST \
            "${JENKINS_URL}/job/student-manager/buildWithParameters?token=${JENKINS_TRIGGER_TOKEN}&GIT_BRANCH=${GITHUB_REF_NAME}" \
            --fail
```

**Cấu hình (một lần):**

1. **Đăng ký self-hosted runner:** GitHub repo → **Settings → Actions → Runners → New self-hosted runner** → làm theo lệnh hướng dẫn (chạy trên máy local có Jenkins). Kết quả: runner hiển thị "Idle".
2. Jenkins job `student-manager` → **Build Triggers** → ✅ **Trigger builds remotely** → đặt token (vd: `capstone-token`)
3. GitHub repo → **Settings → Secrets and variables → Actions → New repository secret**:
   - `JENKINS_URL` = `http://localhost:8080` (self-hosted runner gọi Jenkins cùng máy)
   - `JENKINS_TRIGGER_TOKEN` = token ở bước 2
   - `GH_TOKEN` (tuỳ chọn) = PAT để thao tác GitHub Project/Issues
4. Đẩy file lên GitHub → mỗi lần **push/PR vào `main`/`develop`**, runner gọi Jenkins và pipeline tự chạy.

> 💡 **Tại sao cần self-hosted runner?** GitHub-hosted runner (`ubuntu-latest`) chạy trên cloud của GitHub nên KHÔNG gọi được `localhost` trên máy bạn. Self-hosted runner chạy ngay trên máy local → gọi trực tiếp Jenkins mà **không cần ngrok/webhook/public URL**.

✅ **Checkpoint 1:** App chạy local? `curl localhost:8080/api/students` trả JSON 3 sinh viên? Code đã lên GitHub?

---

## 5. GIAI ĐOẠN 2: CI — BUILD, TEST, STATIC ANALYSIS

### 5.1 Viết Unit Tests

**`src/test/java/com/devops/capstone/controller/StudentControllerTest.java`:**

```java
package com.devops.capstone.controller;

import com.devops.capstone.model.Student;
import com.devops.capstone.repository.StudentRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.*;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class StudentControllerTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private StudentRepository repository;

    private String baseUrl;

    @BeforeEach
    void setUp() {
        baseUrl = "http://localhost:" + port + "/api/students";
        repository.deleteAll();
        repository.save(new Student("SV001", "Nguyen Van A", 20, "K20"));
    }

    @Test
    void testGetAllStudents() {
        ResponseEntity<Map> response = restTemplate.getForEntity(baseUrl, Map.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        Map body = response.getBody();
        assertNotNull(body);
        assertEquals(true, body.get("success"));
        assertNotNull(body.get("data"));
    }

    @Test
    void testGetStudentById() {
        Student saved = repository.findAll().get(0);
        ResponseEntity<Map> response = restTemplate.getForEntity(
            baseUrl + "/" + saved.getId(), Map.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());
    }

    @Test
    void testStudentNotFound() {
        ResponseEntity<Map> response = restTemplate.getForEntity(
            baseUrl + "/9999", Map.class);
        assertEquals(HttpStatus.NOT_FOUND, response.getStatusCode());
    }

    @Test
    void testCreateStudent() {
        Student newStudent = new Student("SV004", "Pham Thi D", 22, "K19");
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Student> request = new HttpEntity<>(newStudent, headers);
        ResponseEntity<Map> response = restTemplate.postForEntity(baseUrl, request, Map.class);
        assertEquals(HttpStatus.CREATED, response.getStatusCode());
    }

    @Test
    void testCreateStudentMissingName() {
        Student invalid = new Student("SV005", null, 20, "K20");
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Student> request = new HttpEntity<>(invalid, headers);
        ResponseEntity<Map> response = restTemplate.postForEntity(baseUrl, request, Map.class);
        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
    }

    @Test
    void testHealthEndpoint() {
        ResponseEntity<Map> response = restTemplate.getForEntity(
            baseUrl + "/health", Map.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        assertEquals("UP", response.getBody().get("status"));
    }

    @Test
    void testSearch() {
        ResponseEntity<Map> response = restTemplate.getForEntity(
            baseUrl + "/search?q=Nguyen", Map.class);
        assertEquals(HttpStatus.OK, response.getStatusCode());
        Map body = response.getBody();
        assertTrue((int) body.get("count") >= 1);
    }
}
```

```bash
# Chạy test
mvn test
# Kết quả: Tests run: 7, Failures: 0, Errors: 0, Skipped: 0 ✅
```

### 5.2 Cấu hình SonarQube

Tạo `sonar-project.properties`:

```properties
sonar.projectKey=student-manager
sonar.projectName=Student Manager — DevOps Capstone
sonar.projectVersion=1.0.0
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.java.coveragePlugin=jacoco
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
sonar.host.url=http://localhost:9000
sonar.login=admin
sonar.password=sonar123
```

#### Cấu hình Quality Gate (plugin SonarQube Scanner + webhook nội bộ)

> Ghi chú: pipeline dùng `withSonarQubeEnv` + `waitForQualityGate`. Webhook này là **nội bộ** giữa 2 container SonarQube ↔ Jenkins (cùng mạng Docker `devops-net`), **không phải** webhook GitHub dùng để trigger pipeline.

**Bước 1 — Cài plugin SonarQube Scanner**
1. Jenkins → **Manage Jenkins → Plugins → Available plugins**
2. Tìm `SonarQube Scanner` → **Install** → restart Jenkins.

**Bước 2 — Tạo token trong SonarQube**
1. Mở `http://localhost:9000` → đăng nhập `admin/admin`
2. Avatar → **My Account → Security → Generate Tokens**
3. Name `jenkins-token` → **Generate** → **copy token** (chỉ hiện 1 lần).

**Bước 3 — Khai báo SonarQube server trong Jenkins**
1. **Manage Jenkins → Configure System → SonarQube servers → Add SonarQube**
2. `Name` = **`SonarQube`** (khớp chuỗi trong `withSonarQubeEnv('SonarQube')`)
3. `Server URL` = **`http://capstone-sonarqube:9000`** (gọi theo tên container, không phải localhost)
4. `Server authentication token` = **Add → Secret text** → dán token ở bước 2 → Save.

**Bước 4 — Cấu hình webhook trong SonarQube**
1. SonarQube → **Administration → Configuration → Webhooks → Create**
2. `Name` = `jenkins`
3. `URL` = **`http://capstone-jenkins:8080/sonarqube-webhook/`** (nếu Jenkins chạy ngoài Docker thì dùng `http://localhost:8080/sonarqube-webhook/`).

**Bước 5 — Kiểm tra Quality Gate (tuỳ chọn)**
- SonarQube → **Quality Gates** → gate mặc định **"Sonar way"** đã áp dụng. Có thể chỉnh ngưỡng (vd coverage ≥ 60%).

**Bước 6 — Chạy pipeline**
- **Build Now** → stage 5 sẽ phân tích rồi **đợi kết quả quality gate** mới chuyển sang stage 6.

> 💡 **Cách đơn giản (bỏ qua quality gate):** nếu chưa cài plugin/webhook, sửa stage 5 trong Jenkinsfile thành `sh 'mvn sonar:sonar -Dsonar.projectKey=student-manager -Dsonar.host.url=${SONAR_HOST_URL} -Dsonar.login=admin -Dsonar.password=sonar123 || true'` (chỉ scan, không chặn build).

### 5.3 Tạo Postman Collection

Tạo file `postman/Student-Manager-API.json` (xem trong `configs/`)

**Tổng hợp lại toàn bộ các endpoint:**

| # | Method | Endpoint                           | Body  | Thành công    | Lỗi   |
| - | ------ | ---------------------------------- | ----- | ------------- | ----- |
| 1 | GET    | `/api/students`                    | Không | `200 OK`      | —     |
| 2 | GET    | `/api/students/{id}`               | Không | `200 OK`      | `404` |
| 3 | POST   | `/api/students`                    | JSON  | `201 Created` | `400` |
| 4 | DELETE | `/api/students/{id}`               | Không | `200 OK`      | `404` |
| 5 | GET    | `/api/students/search?q={keyword}` | Không | `200 OK`      | —     |
| 6 | GET    | `/api/students/health`             | Không | `200 OK`      | —     |


### 5.4 Viết Jenkinsfile for DevOps Pipeline (14 stage — đầy đủ vòng đời DevOps)

File `Jenkinsfile` đã có sẵn trong `configs/Jenkinsfile` (bản đầy đủ 14 stage). Tóm tắt các stage:

| # | Stage | Công cụ |
|---|-------|---------|
| 1 | PLAN | GitHub Project + `gh` issues |
| 2 | CODE | Git Flow + checkout |
| 3 | BUILD | Maven `clean compile` |
| 4 | UNIT TEST | JUnit 5 + JaCoCo |
| 5 | STATIC ANALYSIS | SonarQube (SAST) + Quality Gate |
| 6 | PACKAGE | Maven `.jar` |
| 7 | PUBLISH | Nexus |
| 8 | DOCKER BUILD | Docker image |
| 9 | DOCKER PUSH | Docker Hub |
| 10 | DEPLOY | Docker run + smoke test + rollback |
| 11 | DAST | OWASP ZAP |
| 12 | API TEST | Newman |
| 13 | MONITOR | ELK + Prometheus + Grafana |
| 14 | FEEDBACK | tạo issue → quay lại PLAN |

> ⚠️ Pipeline dùng `withSonarQubeEnv` + `waitForQualityGate` → cần plugin **SonarQube Scanner** và cấu hình **webhook nội bộ** SonarQube → Jenkins (trong cùng Docker network, **không phải** webhook GitHub). Nếu chưa cấu hình, bỏ block `post` của stage 5 và dùng `mvn sonar:sonar ... || true`.

✅ **Checkpoint 2:** `mvn test` 7/7 pass? SonarQube hiển thị project?

---

## 6. GIAI ĐOẠN 3: RELEASE — Package & Publish

### 6.1 Build Artifact

```bash
mvn clean package -DskipTests
ls -lh target/student-manager-1.0.0-SNAPSHOT.jar
# ~30MB Spring Boot fat JAR
```

### 6.2 Publish lên Nexus

1. Cấu hình Nexus: http://localhost:8081 → admin / password
2. Settings → Repositories → Create → maven2(hosted) → `maven-releases_Lab10`
3. Cấu hình Maven `~/.m2/settings.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0
                              https://maven.apache.org/xsd/settings-1.2.0.xsd">

    <servers>
        <server>
            <id>nexus</id>
            <username>admin</username>
            <password>nexus123</password>
        </server>
    </servers>

</settings>
```
**Lưu ý:**
Tạo file C:\Users\UserName (tên tài khoản người dùng trên máy tính windows)\.m2\settings.xml với nội dung như trên.

Ví dụ: C:\Users\FPTSHOP\.m2\settings.xml

4. Deploy:

```bash
mvn deploy -DskipTests -DaltDeploymentRepository=nexus::default::http://localhost:8081/repository/maven-releases_Lab10/
```

5. Verify: Nexus → Browse → maven-releases_Lab10 → `com/devops/capstone/student-manager/1.0.0/`

✅ **Checkpoint 3:** Artifact `.jar` có trong Nexus?

---

## 7. GIAI ĐOẠN 4: CD — DOCKER BUILD & DEPLOY

### 7.1 Viết Dockerfile

```dockerfile
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/student-manager-1.0.0-SNAPSHOT.jar app.jar
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost:8080/api/students/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### 7.2 Docker Build & Run

```bash
docker build -t student-manager:1.0.0 .
docker run -d -p 8080:8080 --name student-manager --network configs_devops-net student-manager:1.0.0
curl http://localhost:8080/api/students/health
```

### 7.3 Push Docker Hub

```bash
docker tag student-manager:1.0.0 YOUR_DOCKER_USER/student-manager:1.0.0
docker login
docker push YOUR_DOCKER_USER/student-manager:1.0.0
```

✅ **Checkpoint 4:** Container running? `curl localhost:8080/api/students/health` → `{"status":"UP"}`?

---

## 8. GIAI ĐOẠN 5: OPERATE — SECURITY TEST & MONITOR

### 8.1 DAST — OWASP ZAP Scan

1. Mở ZAP → Quick Start → Automated Scan
2. URL: `http://localhost:8080`
3. Attack → đợi scan hoàn tất (~3 phút)
4. Report → Generate HTML Report → `zap-report.html`

**Kiểm tra alerts:**
- High: 0 (ứng dụng không có XSS/SQLi vì là REST API)
- Medium: Missing security headers (thêm sau)
- Low: Information disclosure

### 8.2 API Test — Newman

```bash
newman run postman/Student-Manager-API.json --reporters "cli,json" --reporter-json-export newman-report.json
```

### 8.3 Health Monitor Loop

Tạo `scripts/monitor.sh`:

```bash
#!/bin/bash
while true; do
  STATUS=$(curl -s http://localhost:8080/api/students/health | python3 -c "import sys,json; print(json.load(sys.stdin)['status'])" 2>/dev/null || echo "DOWN")
  echo "[$(date '+%H:%M:%S')] Student Manager: $STATUS"
  sleep 5
done
```

```bash
bash scripts/monitor.sh
```

> 📊 **Nâng cao — Observability:** pipeline (stage 13) còn tích hợp **ELK** (Elasticsearch, Logstash, Kibana) để lưu & truy vấn log tập trung, và **Prometheus + Grafana** để giám sát metrics (JVM, HTTP). Xem `docker-compose-infra.yml` + `configs/prometheus/prometheus.yml`.

✅ **Checkpoint 5:** ZAP report có alerts? Newman 5/5 tests pass? Monitor loop chạy?

---

## 9. GIAI ĐOẠN 6: FEEDBACK — TỪ MONITOR VỀ PLAN

### 9.1 Ghi nhận Issues từ Testing

Dựa trên kết quả ZAP + SonarQube:
1. Tạo GitHub Issue: `[SEC-01] Add security headers (CSP, X-Frame-Options)`
2. Tạo GitHub Issue: `[QUAL-01] Increase test coverage above 70%`
3. Gán issue → Developer → Fix → Commit → Push → **Pipeline tự chạy lại!**

### 9.2 Demo Toàn bộ Vòng lặp

```
1. Developer push code lên GitHub
2. Jenkins trigger CI pipeline
3. Build → Test → SonarQube scan → Package → Push Nexus
4. Docker build → Push Docker Hub → Deploy container
5. ZAP security scan → Newman API test → Health monitor
6. Issues found → GitHub Issues created
7. Developer fix → Commit → Push → QUAY LẠI BƯỚC 2 

∞ INFINITE LOOP — DevOps là vòng lặp liên tục!
```

### 9.3 Demo chạy Jenkinsfile for DevOps Pipe tại bước 5.4
BƯỚC 1: Tạo Jenkins Job (type: pipeline), đặt tên Lab10

BƯỚC 2: Setting các tool trên Jenkins: 

**Thực hiện các bước cấu hình ban đầu** trên giao diện Jenkins (Dashboard) và hệ thống máy chủ trước khi chạy `Jenkinsfile` này. Nếu không cấu hình, pipeline sẽ báo lỗi ngắt ngắt (failed) ngay từ các bước đầu tiên.

---

### **a. Cấu hình Công cụ (Global Tool Configuration)**

Truy cập: **Manage Jenkins** $\rightarrow$ **Tools**:

* **Maven:** Thêm Maven với tên **`M3`** (khớp với khai báo `maven 'M3'` trong `Jenkinsfile`). Bạn có thể chọn *Install automatically* phiên bản Maven 3.9.x.
* **JDK:** Thêm JDK với tên **`JDK17`** (khớp với khai báo `jdk 'JDK17'`). Nếu chạy Jenkins trong Docker, đảm bảo cài đặt đúng đường dẫn `JAVA_HOME=/opt/java/openjdk` hoặc khai báo cài tự động Java 17.

---

### **b. Cấu hình Plugins cần thiết**

Truy cập: **Manage Jenkins** $\rightarrow$ **Plugins** $\rightarrow$ **Available plugins** và cài đặt các plugin sau:

* **SonarQube Scanner**: Cần cho stage `5. STATIC ANALYSIS (SAST)` để đọc hàm `withSonarQubeEnv` và `waitForQualityGate()`.
* **JaCoCo Plugin**: Cần cho stage `4. UNIT TEST` để đọc hàm `jacoco(...)`.
* **JUnit Plugin**: Hiển thị báo cáo kết quả Unit Test (`junit 'target/surefire-reports/*.xml'`).
* **Pipeline / Pipeline: Stage View**: Môi trường chạy Pipeline mặc định.

---

### **c. Cấu hình kết nối SonarQube Server**

Truy cập: **Manage Jenkins** $\rightarrow$ **System** (hoặc Configure System):

1. Tìm đến mục **SonarQube servers**.
2. Thêm server mới với các thông tin:
* **Name**: **`SonarQube`** *(Bắt buộc phải gõ đúng tên này vì Jenkinsfile khai báo `withSonarQubeEnv('SonarQube')`)*.
* **Server URL**: `http://capstone-sonarqube:9000`
* **Server authentication token**: Mở SonarQube UI $\rightarrow$ Account $\rightarrow$ Security $\rightarrow$ Generate Token, sau đó lưu Token này vào Jenkins dưới dạng Credentials loại *Secret text*.



---

### **d. Cấu hình Biến môi trường & Credentials (Docker Hub & Environment)**

Trong `Jenkinsfile`, bạn có biến `DOCKER_USER = 'YOUR_DOCKER_USERNAME'`.

* **Sửa trực tiếp trong Jenkinsfile** hoặc khai báo biến môi trường chung trong Jenkins tại **Manage Jenkins** $\rightarrow$ **System** $\rightarrow$ **Global properties** $\rightarrow$ **Environment variables**:
* `DOCKER_USER`: Điền Docker Hub Username thực tế của bạn.


* **Đăng nhập Docker Hub trên Jenkins Node:** Do stage `9. DOCKER PUSH` sử dụng lệnh `docker push` trực tiếp, bạn cần vào terminal của máy/container Jenkins và thực hiện lệnh đăng nhập thủ công 1 lần:
```bash
docker login -u <YOUR_DOCKER_USERNAME>

```

---

### **e. Cấp quyền chạy Docker & Cài đặt công cụ CLI phụ trợ**

* **Quyền chạy Docker:** Container Jenkins cần có quyền tương tác với Docker Socket của máy Host (đã mount `/var/run/docker.sock`). Đảm bảo user `jenkins` có quyền chạy lệnh `docker` mà không bị từ chối quyền (*Permission denied*).
* **Cài đặt Newman (Postman CLI):** Stage `12. API TEST (Newman)` gọi lệnh `newman` trực tiếp. Bạn cần cài đặt Node.js & Newman bên trong môi trường chạy của Jenkins:
```bash
npm install -g newman

```


* **Cài đặt GitHub CLI (Tuỳ chọn):** Nếu muốn dùng tính năng tự động tạo issue ở stage `1. PLAN` và `14. FEEDBACK`, bạn cần cài sẵn `gh` CLI và đăng nhập bằng `gh auth login`.
  
* ĐỐI VỚI NHÓM CÔNG CỤ **Monitoring & Observability** (ELK Stack, Prometheus, Grafana), chúng ta **không cần cài đặt plugin hay công cụ phức tạp** trong Jenkins, vì `Jenkinsfile` sử dụng trực tiếp các lệnh `curl` và `docker logs` để tương tác qua HTTP API.

Tuy nhiên chúng ta cần thực hiện một vài cấu hình thiết yếu trên chính các công cụ đó để hệ thống thu thập được dữ liệu.

---

**a. Prometheus: Cấu hình Scrape Target (Lấy metrics từ App)**

Mở file `./prometheus/prometheus.yml` trên máy host (file bạn đã mount vào Prometheus) và đảm bảo có cấu hình endpoint của Spring Boot Actuator:

```yaml
scrape_configs:
  - job_name: 'student-manager'
    metrics_path: '/actuator/prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['student-manager:8080'] # Tên container app trong cùng Docker Network

```

---

**b. Grafana: Kết nối Prometheus làm Data Source**

1. Truy cập Grafana: `http://localhost:3000` (User/Password: `admin` / `admin`).
2. Vào **Connections** $\rightarrow$ **Data Sources** $\rightarrow$ Chọn **Prometheus**.
3. Điền **Prometheus server URL**: `http://capstone-prometheus:9090` (sử dụng tên container thay vì localhost).
4. Nhấn **Save & test** để xác nhận kết nối thành công.
5. *(Tuỳ chọn)* Import Dashboard mẫu cho Spring Boot (ví dụ Dashboard ID `11378` hoặc `4701`).

---

**c. Kibana: Tạo Index Pattern xem Log**

1. Truy cập Kibana: `http://localhost:5601`.
2. Mở menu góc trái $\rightarrow$ **Stack Management** $\rightarrow$ **Index Patterns** (hoặc Data Views).
3. Nhấn **Create index pattern**:
* **Name**: `student-manager-logs*` (trùng tên index `Jenkinsfile` ghi vào: `student-manager-logs`).
* **Timestamp field**: Chọn `@timestamp`.


4. Vào mục **Discover** trên Kibana để xem và truy vấn log được đẩy về từ Jenkins stage 13.

---

**d. Ứng dụng Spring Boot (`student-manager`)**

Đảm bảo trong dự án Java Spring Boot của bạn đã bổ sung dependency `micrometer-registry-prometheus` và khai báo trong file `application.properties`:

```properties
management.endpoints.web.exposure.include=health,info,prometheus
management.metrics.tags.application=student-manager

```
  
BƯỚC 3: Đẩy Jenkinsfile lên thư mục root của kho code "Student Manager API"

BƯỚC 4: Trigger: Click Build Now


✅ **Checkpoint 6:** Đã tạo issues từ kết quả test? Đã fix 1 issue và push → pipeline chạy lại?



---

## 10. TỔNG KẾT & NỘP BÀI

### Bảng Tổng kết Công cụ đã Dùng

| # | Công cụ | Giai đoạn | Mục đích |
|---|---------|-----------|----------|
| 1 | GitHub | Plan + Code | Lưu trữ code, quản lý issues |
| 2 | Git + Git Flow | Code | Version control, branching |
| 3 | Maven | Build | Compile, test, package |
| 4 | JUnit 5 | Test | Unit testing |
| 5 | SonarQube | Static Analysis | Code quality, bugs, security hotspots |
| 6 | Nexus | Release | Artifact repository |
| 7 | Docker | Release + Deploy | Containerization |
| 8 | Docker Hub | Release | Image registry |
| 9 | Jenkins | Orchestrator | CI/CD pipeline tự động |
| 10 | Postman/Newman | Operate | API functional testing |
| 11 | OWASP ZAP | Operate | Security testing (DAST) |
| 12 | ELK (cluster health, ship log → ES, Kibana, Logstash) + Prometheus/Grafana (metrics, JVM) + Health Endpoint | Monitor | Runtime health check |

### Tiêu chí Chấm điểm

| # | Tiêu chí | Điểm |
|---|----------|:----:|
| 1 | Code + GitHub + Git Flow (Plan & Code) | 15% |
| 2 | Jenkins CI Pipeline (Build → Test → Scan) | 20% |
| 3 | Artifact trên Nexus + Docker Hub | 15% |
| 4 | App deploy thành công (curl health OK) | 15% |
| 5 | SonarQube + ZAP reports | 15% |
| 6 | Newman API tests pass | 10% |
| 7 | Vòng lặp Feedback (issue → fix → pipeline) | 10% |
| **TỔNG** | | **100%** |

### Cách Nộp

```
CAPSTONE_NhomX_HoTen.zip
├── student-manager/              ← Toàn bộ source code
├── Jenkinsfile                   ← CI/CD pipeline
├── Dockerfile                    ← Docker image
├── docker-compose-infra.yml      ← Infrastructure stack
├── sonar-project.properties      ← SonarQube config
├── postman/                      ← Postman collection
├── screenshots/
│   ├── 01-github-repo.png
│   ├── 02-jenkins-pipeline.png   ← Stage View all green
│   ├── 03-sonarqube-dashboard.png
│   ├── 04-nexus-artifact.png
│   ├── 05-docker-hub.png
│   ├── 06-zap-report.png
│   ├── 07-newman-report.png
│   ├── 08-app-running.png        ← curl health + browser
│   └── 09-monitor-loop.png
├── reports/                      ← ZAP + Newman reports
└── CAPSTONE_REPORT.md            ← Báo cáo tổng kết
```

---

## 11. MỞ RỘNG — Triển khai trên AWS EC2 thật

> ☁️ Muốn thực hành **vận hành & bảo trì trên hạ tầng cloud thật**? Xem hướng dẫn đầy đủ:
>
> 📄 [`CAPSTONE_AWS_EC2.md`](./CAPSTONE_AWS_EC2.md) — dựng EC2, dùng ECR thay Docker Hub, IaC bằng Terraform (Bài 3), CloudWatch + ELK + Prometheus/Grafana, và **dọn dẹp tránh phát sinh chi phí**.
>
> 👉 Phần phân tích **"Vận hành & Bảo trì phần mềm trong Jenkins DevOps Pipeline"** (ánh xạ 4 loại bảo trì + Observability) xem ở [`README.md`](./README.md).

---

> 🏆 **CAPSTONE HOÀN THÀNH!** Bạn đã xây dựng DevOps Pipeline end-to-end: Plan → Code → Build → Test → Scan → Package → Release → Deploy → Operate → Monitor → Feedback.
>
> **Ánh xạ 9 bài học:**
> Plan(1) → Code(5) → Build(7) → Test(6) → Scan(6) → Package(7) → Release(7,8) → Deploy(8) → Operate(2,9) → Monitor(2) → Plan(1)
>
> 📅 **Cập nhật:** 2026-08-31
