// ============================================================================
//  Jenkinsfile — Student Manager | DevOps End-to-End Pipeline (vòng lặp khép kín)
//
//  Vòng đời DevOps đầy đủ (12 giai đoạn / 6 phase):
//
//    PHASE 1  PLAN & CODE   1. PLAN → 2. CODE
//    PHASE 2  CI            3. BUILD → 4. UNIT TEST → 5. STATIC ANALYSIS (SAST)
//    PHASE 3  RELEASE       6. PACKAGE → 7. PUBLISH (Nexus)
//    PHASE 4  CD            8. DOCKER BUILD → 9. DOCKER PUSH → 10. DEPLOY
//    PHASE 5  OPERATE       11. DAST (OWASP ZAP) → 12. API TEST (Newman)
//    PHASE 6  MONITOR       13. MONITOR (ELK + Prometheus + Grafana)
//                           → 14. FEEDBACK → (quay lại PLAN)  ∞ LOOP
//
//  Bài học ánh xạ: Plan(1) Code(5) Build(7) Test(6) Scan(6) Package(7)
//                  Release(7,8) Deploy(8) Operate(6,2) Monitor(2,9) Plan(1)
//
//  Trigger: GitHub Action (.github/workflows/trigger-jenkins.yml) gọi Jenkins
//           "remote build API" khi push/PR vào main/develop.
//           Repo: https://github.com/PhamThuongBlog/student-manager.git
// ============================================================================

pipeline {
    agent any

    tools {
        maven 'M3'      // Maven 3.9.x (đã cấu hình ở Manage Jenkins → Tools)
        jdk   'JDK17'   // JDK 21 (JAVA_HOME=/opt/java/openjdk)
    }

    parameters {
        string(name: 'GIT_BRANCH',  defaultValue: 'main',           description: 'Branch triển khai (Git Flow)')
        string(name: 'DOCKER_IMAGE', defaultValue: 'student-manager', description: 'Tên Docker image')
        choice(name: 'DEPLOY_ENV',  choices: ['dev', 'staging', 'prod'], description: 'Môi trường triển khai')
        booleanParam(name: 'RUN_DAST',    defaultValue: true, description: 'Chạy OWASP ZAP (DAST security scan)')
        booleanParam(name: 'RUN_MONITOR', defaultValue: true, description: 'Chạy Monitor + Feedback loop')
    }

    environment {
        // ---------- Ứng dụng ----------
        APP_NAME     = 'student-manager'
        APP_PORT     = '8082'
        APP_VERSION  = '1.0.0'

        // ---------- Công cụ CI/CD ----------
        SONAR_HOST_URL = 'http://capstone-sonarqube:9000'
        NEXUS_URL      = 'http://capstone-nexus:8081'
        DOCKER_USER    = 'phamthuongdocker'

        // ---------- Monitoring: ELK + Prometheus + Grafana ----------
        ELASTICSEARCH_URL = 'http://capstone-elasticsearch:9200'
        KIBANA_URL        = 'http://capstone-kibana:5601'
        LOGSTASH_URL      = 'http://capstone-logstash:9600'
        PROMETHEUS_URL    = 'http://capstone-prometheus:9090'
        GRAFANA_URL       = 'http://capstone-grafana:3000'
    }

    stages {

        // ======================================================================
        //  PHASE 1 — PLAN & CODE
        // ======================================================================

        stage('1. PLAN') {
            steps {
                echo '🗺️  PLAN — Đồng bộ GitHub Project & Issues (plan liên tục)'
                script {
                    // Đối chiếu repository / branch đang build
                    def repo = sh(script: 'git remote get-url origin 2>/dev/null || echo "no-remote"', returnStdout: true).trim()
                    def br   = sh(script: 'git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "n/a"', returnStdout: true).trim()
                    echo "   📌 Repository : ${repo}"
                    echo "   🌿 Branch      : ${br}"

                    // Plan liên tục: đọc backlog + tạo issue trên GitHub Project
                    //   gh issue list --repo PhamThuongBlog/student-manager --state open --limit 10
                    //   gh issue create --repo PhamThuongBlog/student-manager \
                    //     --title "[BUILD-${BUILD_NUMBER}] Deploy ${params.DEPLOY_ENV}" \
                    //     --body "Pipeline tự động khởi chạy." || true
                    def gh = sh(script: 'command -v gh >/dev/null 2>&1 && echo "ready" || echo "skip (không bắt buộc)"', returnStdout: true).trim()
                    echo "   gh CLI       : ${gh}"
                }
            }
        }

        stage('2. CODE') {
            steps {
                echo '💻 CODE — Checkout + kiểm tra Git Flow'
                checkout scm

                script {
                    sh '''
                        echo "   - HEAD commit : $(git log -1 --oneline)"
                        echo "   - Tác giả     : $(git log -1 --pretty=%an)"
                        echo "   - Thời điểm   : $(git log -1 --pretty=%cd)"
                    '''
                    // Cảnh báo nếu đang merge trực tiếp vào main (không qua Git Flow)
                    def branch = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    if (branch == 'main') {
                        echo '   ⚠️  Đang build trên main — nên dùng Git Flow (feature → develop → release → main).'
                    } else {
                        echo "   ✅ Git Flow OK — branch '${branch}' hợp lệ."
                    }
                }
            }
        }

        // ======================================================================
        //  PHASE 2 — CI (Continuous Integration)
        // ======================================================================

        stage('3. BUILD') {
            steps {
                echo '🔨 BUILD — Maven clean compile (Java 17)'
                sh 'mvn clean compile'
            }
            post {
                failure {
                    echo '❌ Compile lỗi — dừng pipeline (fast feedback).'
                }
            }
        }

        stage('4. UNIT TEST') {
            steps {
                echo '🧪 UNIT TEST — JUnit 5 + JaCoCo coverage'
                sh 'mvn test'
            }
            post {
                always {
                    // Publish kết quả test lên Jenkins UI (Test Result Trend)
                    junit 'target/surefire-reports/*.xml'
                    // JaCoCo coverage report
                    jacoco(
                        execPattern: 'target/jacoco.exec',
                        classPattern: 'target/classes',
                        sourcePattern: 'src/main/java'
                    )
                }
            }
        }

        stage('5. STATIC ANALYSIS (SAST)') {
            steps {
                echo '🔍 SAST — SonarQube scan + Quality Gate'
                withSonarQubeEnv('SonarQube') {   // <-- đổi tên server theo cấu hình của bạn
                    sh 'mvn sonar:sonar -Dsonar.projectKey=student-manager -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml'
                }
            }
            post {
                always {
                    // Đợi SonarQube trả Quality Gate.
                    // (webhook NỘI BỘ SonarQube→Jenkins trong cùng Docker network,
                    //  KHÔNG phải webhook GitHub dùng cho trigger pipeline)
                    script {
                        timeout(time: 5, unit: 'MINUTES') {
                            def qg = waitForQualityGate()
                            if (qg.status != 'OK') {
                                error "❌ SonarQube Quality Gate FAILED: ${qg.status}"
                            }
                        }
                    }
                }
            }
        }

        // ======================================================================
        //  PHASE 3 — RELEASE (Package & Publish)
        // ======================================================================

        stage('6. PACKAGE') {
            steps {
                echo '📦 PACKAGE — Maven đóng gói .jar'
                sh 'mvn package -DskipTests'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('7. PUBLISH TO NEXUS') {
            steps {
                echo '📤 RELEASE — Upload artifact lên Nexus Repository'
                withCredentials([usernamePassword(credentialsId: 'nexus-credentials', usernameVariable: 'NEXUS_USER', passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                        cat > nexus-settings.xml <<EOF
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0">
  <servers>
    <server>
      <id>nexus</id>
      <username>${NEXUS_USER}</username>
      <password>${NEXUS_PASS}</password>
    </server>
  </servers>
</settings>
EOF
                        mvn deploy -DskipTests -s nexus-settings.xml -DaltDeploymentRepository=nexus::default::${NEXUS_URL}/repository/maven-releases_lab10/
                    '''
                }
            }
        }

        // ======================================================================
        //  PHASE 4 — CD (Continuous Delivery / Deployment)
        // ======================================================================

        stage('8. DOCKER BUILD') {
            steps {
                echo '🐳 CONTAINER BUILD — Build Docker image'
                sh 'docker build -t ${APP_NAME}:${BUILD_NUMBER} .'
            }
        }

        stage('9. DOCKER PUSH') {
            steps {
                echo '📤 REGISTRY PUSH — Push image lên Docker Hub'
                sh '''
                    docker tag ${APP_NAME}:${BUILD_NUMBER} ${DOCKER_USER}/${APP_NAME}:${BUILD_NUMBER}
                    docker tag ${APP_NAME}:${BUILD_NUMBER} ${DOCKER_USER}/${APP_NAME}:latest
                    docker push ${DOCKER_USER}/${APP_NAME}:${BUILD_NUMBER}
                    docker push ${DOCKER_USER}/${APP_NAME}:latest
                '''
            }
        }

        stage('10. DEPLOY') {
            steps {
                echo '🚀 DEPLOY — Chạy container + smoke test'
                sh '''
                    docker stop ${APP_NAME} 2>/dev/null || true
                    docker rm ${APP_NAME} 2>/dev/null || true
                    docker run -d --name ${APP_NAME} \
                        --network configs_devops-net \
                        -p ${APP_PORT}:8082 \
                        ${DOCKER_USER}/${APP_NAME}:${BUILD_NUMBER}
                '''
                // Đợi container healthy (healthcheck trong Dockerfile) rồi smoke test
                script {
                    def healthy = false
                    for (int i = 1; i <= 20; i++) {
                        def out = sh(script: 'curl -sf http://${APP_NAME}:8082/api/students/health || true', returnStdout: true).trim()
                        if (out.contains('UP')) { healthy = true; break }
                        sleep 2
                    }
                    if (!healthy) { error '❌ App không lên healthy sau 40s — rollback cần thiết.' }
                    echo '   ✅ Health check UP — deploy thành công.'
                }
            }
            post {
                failure {
                    // Rollback: chạy lại image `latest` đã ổn định trước đó
                    echo '↩️  ROLLBACK — khôi phục image latest...'
                    sh 'docker run -d --name ${APP_NAME} --network configs_devops-net -p ${APP_PORT}:8082 ${DOCKER_USER}/${APP_NAME}:latest || true'
                }
            }
        }

        // ======================================================================
        //  PHASE 5 — OPERATE (Security & API Test)
        // ======================================================================

        stage('11. DAST (OWASP ZAP)') {
            when { expression { params.RUN_DAST } }
            steps {
                echo '🛡️  DAST — OWASP ZAP security scan'
                // ZAP baseline scan (image cũ owasp/zap2docker-stable đã bị xóa, dùng zaproxy/zap-stable)
                sh '''
                    # Tạo sẵn thư mục reports với quyền ghi để container ZAP (user zap) ghi được report
                    mkdir -p reports
                    chmod 777 reports

                    # docker-in-docker: flag -v dùng path trên HOST (volume jenkins_home),
                    # KHÔNG phải path bên trong container Jenkins. Nên phải lấy host path thật.
                    JH_HOME=$(docker inspect capstone-jenkins --format '{{range .Mounts}}{{if eq .Destination "/var/jenkins_home"}}{{.Source}}{{end}}{{end}}')
                    REPORT_DIR="${JH_HOME}/workspace/Lab10/reports"

                    docker run --rm --network configs_devops-net \
                        -v "${REPORT_DIR}:/zap/wrk" \
                        zaproxy/zap-stable zap-baseline.py \
                        -t http://${APP_NAME}:8082 \
                        -r zap-report.html -J zap-report.json || true
                '''
            }
        }

        stage('12. API TEST (Newman)') {
            steps {
                echo '🧪 API TEST — Newman chạy Postman collection'
                sh '''
                    newman run postman/Student-Manager-API.json \
                        --reporters cli,json \
                        --reporter-json-export newman-report.json || true
                '''
            }
        }

        // ======================================================================
        //  PHASE 6 — MONITOR & FEEDBACK (quay lại PLAN)
        // ======================================================================

        stage('13. MONITOR') {
            when { expression { params.RUN_MONITOR } }
            steps {
                echo '📊 MONITOR — Observability: ELK + Prometheus + Grafana'
                script {
                    // ---- ELK Stack: Elasticsearch + Logstash + Kibana ----
                    def es = sh(script: "curl -s ${ELASTICSEARCH_URL}/_cluster/health || true", returnStdout: true).trim()
                    echo "   Elasticsearch cluster: ${es}"

                    // Ship log ứng dụng vào Elasticsearch (đóng vai Filebeat → Logstash → ES)
                    // Dùng node để JSON-escape log line đúng chuẩn (tránh lỗi JSON khi log có ký tự đặc biệt)
                    sh '''
                        docker logs --tail 50 ${APP_NAME} 2>&1 \
                          | while IFS= read -r line; do
                              TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
                              BODY=$(node -e 'console.log(JSON.stringify({log:process.argv[1],"@timestamp":process.argv[2]}))' "$line" "$TS")
                              curl -s -X POST "${ELASTICSEARCH_URL}/student-manager-logs/_doc" \
                                -H 'Content-Type: application/json' \
                                -d "$BODY" >/dev/null 2>&1
                            done || true
                    '''
                    def kibana = sh(script: "curl -s -o /dev/null -w '%{http_code}' ${KIBANA_URL}/api/status || true", returnStdout: true).trim()
                    echo "   Kibana (dashboard)  : HTTP ${kibana}"

                    def logstash = sh(script: "curl -s ${LOGSTASH_URL} || true", returnStdout: true).trim()
                    echo "   Logstash (pipeline) : ${logstash}"

                    // ---- Metrics: Prometheus + Grafana (Spring Boot Actuator) ----
                    def promUp = sh(script: "curl -s '${PROMETHEUS_URL}/api/v1/query?query=up' || true", returnStdout: true).trim()
                    echo "   Prometheus targets  : ${promUp}"

                    def jvmMem = sh(script: "curl -s '${PROMETHEUS_URL}/api/v1/query?query=jvm_memory_used_bytes' || true", returnStdout: true).trim()
                    echo "   JVM memory metric   : ${jvmMem}"

                    def grafana = sh(script: "curl -s -o /dev/null -w '%{http_code}' ${GRAFANA_URL}/api/health || true", returnStdout: true).trim()
                    echo "   Grafana (dashboard) : HTTP ${grafana}"

                    // ---- Health endpoint cuối cùng của ứng dụng ----
                    def app = sh(script: 'curl -s http://${APP_NAME}:8082/api/students/health || echo DOWN', returnStdout: true).trim()
                    echo "   App health          : ${app}"
                }
            }
        }

        stage('14. FEEDBACK') {
            when { expression { params.RUN_MONITOR } }
            steps {
                echo '🔄 FEEDBACK — Tổng hợp findings → tự động tạo GitHub Issues'
                withCredentials([string(credentialsId: 'github-token', variable: 'GH_TOKEN')]) {
                    sh '''
                        ISSUES_FILE=issues.tmp
                        : > "$ISSUES_FILE"

                        # 1) Newman: đếm assertion thất bại từ newman-report.json
                        NF=$(node -e 'try{const r=require("./newman-report.json");console.log((r.run.failures||[]).length)}catch(e){console.log(-1)}')
                        if [ "$NF" -gt 0 ]; then
                            echo "TEST: $NF assertion(s) API thất bại" >> "$ISSUES_FILE"
                        fi

                        # 2) Prometheus: app student-manager down?
                        UP=$(curl -s "${PROMETHEUS_URL}/api/v1/query?query=up%7Bjob%3D%22student-manager%22%7D" || true)
                        if ! echo "$UP" | grep -q '"1"'; then
                            echo "MONITOR: app student-manager DOWN" >> "$ISSUES_FILE"
                        fi

                        # 3) Elasticsearch: có log ERROR?
                        ERR=$(curl -s "${ELASTICSEARCH_URL}/student-manager-logs/_count" -H 'Content-Type: application/json' -d '{"query":{"match":{"log":"ERROR"}}}' || true)
                        if echo "$ERR" | grep -qE '"count":[1-9]'; then
                            echo "LOG: phát hiện log ERROR trong Elasticsearch" >> "$ISSUES_FILE"
                        fi

                        # 4) ZAP: có alert High/Critical? (dùng zap-report.json)
                        if [ -f reports/zap-report.json ]; then
                            ZAP_HIGH=$(node -e 'try{const r=require("./reports/zap-report.json");let n=0;for(const s of (r.sites||[])){for(const a of (s.alerts||[])){if(a.risk==="High"||a.risk==="Critical")n++}}console.log(n)}catch(e){console.log(-1)}')
                            if [ "$ZAP_HIGH" -gt 0 ]; then
                                echo "SEC: $ZAP_HIGH alert ZAP High/Critical" >> "$ISSUES_FILE"
                            fi
                        fi

                        # 5) Tạo issue trên GitHub (REST API + token từ Jenkins credential)
                        COUNT=0
                        while IFS= read -r TITLE; do
                            [ -z "$TITLE" ] && continue
                            BODY=$(node -e 'console.log(JSON.stringify(process.argv[1]))' "Tự động sinh từ pipeline Lab10. Xem build: ${BUILD_URL}")
                            PAYLOAD=$(node -e 'console.log(JSON.stringify({title:process.argv[1],body:process.argv[2],labels:["automated"]}))' "[BUILD-${BUILD_NUMBER}] $TITLE" "$BODY")
                            curl -s -X POST \
                                -H "Authorization: token ${GH_TOKEN}" \
                                -H "Accept: application/vnd.github+json" \
                                -d "$PAYLOAD" \
                                https://api.github.com/repos/PhamThuongBlog/student-manager/issues >/dev/null
                            COUNT=$((COUNT+1))
                        done < "$ISSUES_FILE"

                        echo "   ✅ Đã tạo $COUNT GitHub issue(s)."
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "🎉 PIPELINE THÀNH CÔNG — vòng đời DevOps hoàn tất cho build #${BUILD_NUMBER}."
        }
        failure {
            echo "💥 PIPELINE THẤT BẠI — kiểm tra logs ở từng stage bên trên."
        }
        always {
            // Lưu trữ artifact & report cho việc truy vết sau này
            archiveArtifacts artifacts: 'reports/**/*, newman-report.json', fingerprint: true, allowEmptyArchive: true
            cleanWs()
        }
    }
}
