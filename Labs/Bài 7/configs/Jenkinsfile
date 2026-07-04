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
                echo '🔍 STEP 4/6: SCAN — Phân tích mã nguồn tĩnh với SonarQube...'
                script {
                    try {
                        withSonarQubeEnv('SonarQube') {
                            sh 'mvn sonar:sonar -Dsonar.projectKey=devops-lab7 -Dsonar.projectName="DevOps Lab 7 CI Demo"'
                        }
                    } catch (Exception e) {
                        echo "⚠️  SonarQube scan skipped (server may not be configured). Error: ${e.getMessage()}"
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
                        echo "⚠️  Nexus publish skipped (repository may not be configured). Error: ${e.getMessage()}"
                    }
                }
            }
        }
    }

    post {
        success {
            echo '🎉 PIPELINE SUCCESS — CI Pipeline hoàn thành!'
            echo "Pipeline completed in ${currentBuild.duration}ms"
        }
        failure {
            echo '💥 PIPELINE FAILED — Kiểm tra logs ở trên để debug!'
        }
        always {
            echo "Build #${currentBuild.number} finished. Duration: ${currentBuild.duration}ms"
            cleanWs()
        }
    }
}
