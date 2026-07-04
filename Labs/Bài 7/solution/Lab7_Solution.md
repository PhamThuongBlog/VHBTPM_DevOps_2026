# Lab 7 — Đáp án (Dành cho Giảng viên)

> **KHÔNG chia sẻ file này cho sinh viên!**

---

## Tổng quan

Lab yêu cầu sinh viên dựng CI pipeline hoàn chỉnh với:
- **Jenkins** (CI Server) — Pipeline tự động hóa build/test/package/deploy
- **Nexus** (Repository Manager) — Lưu trữ artifacts
- **SonarQube** (Code Analysis) — Phân tích mã nguồn tĩnh
- **GitHub** — Quản lý source code + trigger webhook
- **Maven** — Build tool cho Java project

Kết quả: Pipeline 6 stages chạy thành công, artifact được upload lên Nexus.

---

## Đáp án Kiến trúc

```
┌──────────────────────────────────────────────────────────┐
│                    Docker Network (ci-network)            │
│                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐           │
│  │ Jenkins  │    │  Nexus   │    │SonarQube │           │
│  │  :8080   │    │  :8081   │    │  :9000   │           │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘           │
│       │               │               │                  │
│       │ mvn build     │ upload .jar   │ code scan        │
│       ▼               ▼               ▼                  │
│  ┌──────────────────────────────────────────┐           │
│  │           Sample Java App (GitHub)        │           │
│  │    Calculator.java + CalculatorTest.java │           │
│  └──────────────────────────────────────────┘           │
└──────────────────────────────────────────────────────────┘
```

---

## Đáp án Jenkinsfile (Hoàn chỉnh)

```groovy
pipeline {
    agent any

    tools {
        maven 'M3'
    }

    environment {
        NEXUS_URL      = 'http://lab7-nexus:8081'
        NEXUS_REPO     = 'maven-releases'
        SONAR_HOST_URL = 'http://lab7-sonarqube:9000'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📦 STEP 1/6: CHECKOUT — Lấy code từ GitHub...'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo '🔨 STEP 2/6: BUILD — Biên dịch với Maven...'
                sh 'mvn clean compile'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 STEP 3/6: TEST — Chạy Unit Tests với JUnit 5...'
                sh 'mvn test'
            }
            post {
                success {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo '🔍 STEP 4/6: SCAN — Phân tích mã nguồn tĩnh...'
                script {
                    try {
                        withSonarQubeEnv('SonarQube') {
                            sh 'mvn sonar:sonar -Dsonar.projectKey=devops-lab7'
                        }
                    } catch (Exception e) {
                        echo "⚠️  SonarQube skipped: ${e.getMessage()}"
                    }
                }
            }
        }

        stage('Package') {
            steps {
                echo '📦 STEP 5/6: PACKAGE — Đóng gói .jar...'
                sh 'mvn package -DskipTests'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Publish to Nexus') {
            steps {
                echo '📤 STEP 6/6: PUBLISH — Đẩy artifact lên Nexus...'
                script {
                    try {
                        sh '''
                            mvn deploy:deploy-file \
                                -DgroupId=com.devops.lab7 \
                                -DartifactId=ci-demo \
                                -Dversion=1.0.0 \
                                -Dpackaging=jar \
                                -Dfile=target/ci-demo-1.0.0-SNAPSHOT.jar \
                                -Durl=http://lab7-nexus:8081/repository/maven-releases/ \
                                -DrepositoryId=nexus
                        '''
                    } catch (Exception e) {
                        echo "⚠️  Nexus skipped: ${e.getMessage()}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo '🎉 PIPELINE SUCCESS!'
        }
        failure {
            echo '💥 PIPELINE FAILED!'
        }
        always {
            cleanWs()
        }
    }
}
```

---

## Kết quả Mong đợi

### Console Output (rút gọn)
```
[Pipeline] Start of Pipeline
[Pipeline] node
Running on Jenkins in /var/jenkins_home/workspace/DevOps-Lab7-CI-Pipeline

[Pipeline] stage (Checkout)
Cloning repository https://github.com/<USER>/devops-lab7-ci-demo.git

[Pipeline] stage (Build)
+ mvn clean compile
[INFO] BUILD SUCCESS

[Pipeline] stage (Test)
+ mvn test
Tests run: 6, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS

[Pipeline] stage (Package)
+ mvn package -DskipTests
[INFO] BUILD SUCCESS
Archiving artifacts: target/ci-demo-1.0.0-SNAPSHOT.jar

[Pipeline] End of Pipeline
Finished: SUCCESS
```

### Pipeline Stage View (mong đợi)
```
Checkout   Build     Test     SonarQube   Package   Publish Nexus
  ✅        ✅        ✅         ✅          ✅          ✅
 (8s)     (22s)     (15s)     (40s)       (6s)       (4s)
```

### Test Results (JUnit)
```
CalculatorTest
  ✅ testAdd              — 0.002s
  ✅ testSubtract         — 0.001s
  ✅ testMultiply         — 0.001s
  ✅ testDivide           — 0.001s
  ✅ testDivideByZero     — 0.001s
  ✅ testIsPositive       — 0.001s
Total: 6/6 PASS, 0 FAIL
```

---

## Các Lỗi Sinh viên Thường Gặp

| # | Lỗi | Nguyên nhân | Cách hướng dẫn |
|---|------|------------|----------------|
| 1 | Docker không đủ RAM | SonarQube cần ≥ 2GB | Tăng Docker memory lên 6GB+ |
| 2 | Jenkins không checkout được GitHub repo | Repo private, chưa config credentials | Tạo Personal Access Token trên GitHub |
| 3 | `mvn: command not found` trong pipeline | Chưa config Maven trong Jenkins Tools | Vào Manage Jenkins → Tools → Maven |
| 4 | Pipeline stuck ở "Pending — Waiting for next available executor" | Node offline | Manage Jenkins → Nodes → Built-in Node → # executors = 2 |
| 5 | SonarQube `Connection refused` | SonarQube chưa khởi động xong (cần ~2 phút) | Đợi thêm, kiểm tra `docker logs lab7-sonarqube` |
| 6 | Nexus 401 Unauthorized | Chưa config credentials cho Nexus | Thêm `credentials('nexus-credentials')` trong Jenkins |
| 7 | `docker.sock: permission denied` | Jenkins container không có quyền | Thêm `user: root` hoặc `group_add` trong docker-compose |
| 8 | `pom.xml not found` | Jenkinsfile chạy sai thư mục | Thêm `dir('sample-java-app')` nếu Jenkinsfile ở root |
| 9 | SonarQube scan bị skip trong pipeline | Chưa config SonarQube server trong Jenkins | Manage Jenkins → System → SonarQube servers |
| 10 | Quên dọn dẹp → hết disk | Docker volumes tích lũy | `docker compose down -v` để xóa volumes |

---

## Câu hỏi Vấn đáp

1. **"Sự khác biệt giữa Declarative và Scripted Pipeline trong Jenkins?"**
   → Declarative: cấu trúc cố định (`pipeline { stages { stage { steps {} } } }`), dễ đọc, phù hợp CI/CD chuẩn. Scripted: viết bằng Groovy tự do, linh hoạt hơn nhưng phức tạp hơn.

2. **"Tại sao dùng `mvn package -DskipTests` thay vì `mvn package` trong stage Package?"**
   → Vì tests đã chạy ở stage Test trước đó. `-DskipTests` bỏ qua compile test + chạy test, tiết kiệm thời gian.

3. **"`archiveArtifacts` trong Jenkins làm gì? Khác gì với Nexus?"**
   → `archiveArtifacts` lưu artifact trong Jenkins (gắn với build cụ thể). Nexus là kho artifact tập trung, dùng cho toàn tổ chức.

4. **"Nếu bạn muốn chạy Test và SonarQube song song, làm thế nào?"**
   → Dùng `parallel` block:
   ```groovy
   stage('Validation') {
       parallel {
           stage('Test') { steps { sh 'mvn test' } }
           stage('Scan') { steps { sh 'mvn sonar:sonar' } }
       }
   }
   ```

5. **"SonarQube tìm thấy những loại vấn đề gì trong code?"**
   → Bugs (lỗi logic), Vulnerabilities (bảo mật), Code Smells (code khó bảo trì), Security Hotspots, Coverage (độ bao phủ test).

---

## Tiêu chí Chấm điểm Chi tiết

| Tiêu chí | Điểm | Cách chấm cụ thể |
|----------|:----:|------------------|
| Docker Stack (3 containers) | 15 | `docker ps` cho thấy lab7-jenkins, lab7-nexus, lab7-sonarqube đều Up |
| Sample Project (mvn test OK) | 10 | `mvn test` → 6 tests PASS, BUILD SUCCESS |
| Jenkinsfile ≥ 4 stages | 20 | Có Checkout, Build, Test, Package (có SonarQube + Nexus là điểm cộng) |
| Pipeline Job Config | 15 | Job configured, Git URL đúng, Jenkinsfile path đúng |
| Build + Test Stage PASS | 15 | Console output: `mvn compile` + `mvn test` = BUILD SUCCESS |
| Package + Artifact archived | 10 | Artifact tab hiển thị file .jar |
| Nexus artifact uploaded | 10 | Nexus web → Browse → maven-releases → có file |
| Cleanup | 5 | `docker ps` không còn lab7 containers |
| **TỔNG** | **100** | |

### Xếp loại:
- **Giỏi (≥85):** Đủ 6 stages + SonarQube + Nexus hoạt động + bài tập mở rộng
- **Khá (70-84):** 4-5 stages hoạt động, build/test/package pass
- **TB (50-69):** Pipeline chạy nhưng có stage fail, chưa config đúng
- **Yếu (<50):** Chưa dựng được Jenkins, pipeline chưa chạy
