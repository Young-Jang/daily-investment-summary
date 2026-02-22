# ─── Build Stage ─────────────────────────────────────────────────────────────
FROM gradle:8.6-jdk21-alpine AS builder
WORKDIR /app

# 의존성 캐시 레이어 (소스 변경 시 재다운로드 방지)
COPY build.gradle.kts settings.gradle.kts ./
COPY gradle gradle
RUN gradle dependencies --no-daemon --quiet || true

# 소스 빌드
COPY src src
RUN gradle bootJar --no-daemon --parallel -x test

# ─── Run Stage ───────────────────────────────────────────────────────────────
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# 보안: 전용 유저 생성
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

COPY --from=builder /app/build/libs/*.jar app.jar
USER appuser
EXPOSE 8080

# JVM: 컨테이너 메모리 인식 + GC 최적화
ENV JAVA_OPTS="-XX:+UseContainerSupport \
               -XX:MaxRAMPercentage=75.0 \
               -XX:+UseG1GC \
               -Djava.security.egd=file:/dev/./urandom"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]

# Docker 자체 헬스체크 (Spring Actuator /actuator/health 사용)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health | grep -q '"status":"UP"' || exit 1
