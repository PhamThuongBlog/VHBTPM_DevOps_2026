FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY target/student-manager-1.0.0-SNAPSHOT.jar app.jar
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8080/api/students/health || exit 1
ENTRYPOINT ["java", "-jar", "app.jar"]
