# ─── Build Stage ─────────────────────────────────────────────────────────────
FROM debian:stable-slim AS builder

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK 설치
RUN git clone https://github.com/flutter/flutter.git /flutter \
    --branch stable --single-branch --depth 1
ENV PATH="/flutter/bin:${PATH}"
# flutter doctor 생략, web 캐시만 다운로드 (메모리 절약)
RUN flutter precache --web --no-android --no-ios --no-linux --no-macos --no-windows --no-fuchsia

# 의존성 캐시 레이어
WORKDIR /app
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# 소스 빌드 (API_BASE_URL은 빌드 인자로 주입)
# FLUTTER_WEB_USE_SKIA=false: 메모리 절약 / --no-tree-shake-icons: 빌드 속도 향상
COPY . .
ARG API_BASE_URL=http://localhost:8080
ENV FLUTTER_WEB_USE_SKIA=false
RUN flutter build web --release \
    --dart-define=API_BASE_URL=${API_BASE_URL} \
    --no-tree-shake-icons

# ─── Serve Stage ─────────────────────────────────────────────────────────────
FROM nginx:1.25-alpine
COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

# Nginx 헬스체크
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost/index.html | grep -q "Flutter" || exit 1
