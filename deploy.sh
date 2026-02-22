#!/usr/bin/env bash
# =============================================================================
# deploy.sh — 일일 투자 정보 요약 서비스 원클릭 배포 스크립트
# 사용법: ./deploy.sh [옵션]
#   옵션:
#     --build-only   빌드만 수행 (컨테이너 재시작 없음)
#     --no-cache     Docker 캐시 없이 빌드
#     --pull         Git pull 후 배포
#     --rollback     이전 이미지로 롤백
# =============================================================================
set -euo pipefail

# ─── 색상 정의 ────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ─── 설정 ─────────────────────────────────────────────────────────────────────
PROJECT_NAME="investment-summary"
COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
HEALTH_TIMEOUT=180   # 헬스체크 최대 대기 시간 (초)
HEALTH_INTERVAL=5    # 헬스체크 폴링 간격 (초)

# ─── 옵션 파싱 ────────────────────────────────────────────────────────────────
BUILD_ONLY=false
NO_CACHE=false
DO_PULL=false
DO_ROLLBACK=false

for arg in "$@"; do
  case $arg in
    --build-only) BUILD_ONLY=true ;;
    --no-cache)   NO_CACHE=true ;;
    --pull)       DO_PULL=true ;;
    --rollback)   DO_ROLLBACK=true ;;
    *)
      echo -e "${RED}알 수 없는 옵션: $arg${NC}"
      echo "사용법: ./deploy.sh [--build-only] [--no-cache] [--pull] [--rollback]"
      exit 1 ;;
  esac
done

# ─── 헬퍼 함수 ────────────────────────────────────────────────────────────────
log_info()    { echo -e "${CYAN}[INFO]${NC}  $*"; }
log_success() { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $*"; }
log_step()    { echo -e "\n${BOLD}${BLUE}━━━ $* ━━━${NC}"; }

check_command() {
  if ! command -v "$1" &>/dev/null; then
    log_error "$1 이(가) 설치되어 있지 않습니다."
    exit 1
  fi
}

# ─── 사전 검사 ────────────────────────────────────────────────────────────────
log_step "사전 요구사항 확인"

check_command docker
check_command docker-compose 2>/dev/null || check_command "docker compose"

# docker-compose 명령 통합 (v1/v2 대응)
if command -v docker-compose &>/dev/null; then
  DC="docker-compose"
else
  DC="docker compose"
fi

if [ ! -f "$ENV_FILE" ]; then
  log_error ".env 파일이 없습니다. .env.example을 복사하여 설정하세요:"
  echo "  cp .env.example .env && vi .env"
  exit 1
fi

# GEMINI_API_KEY 필수 체크
source "$ENV_FILE"
if [ -z "${GEMINI_API_KEY:-}" ]; then
  log_error "GEMINI_API_KEY가 .env에 설정되지 않았습니다."
  exit 1
fi

log_success "사전 검사 통과"

# ─── 롤백 ─────────────────────────────────────────────────────────────────────
if [ "$DO_ROLLBACK" = true ]; then
  log_step "이전 버전으로 롤백"
  BACKUP_TAG="${PROJECT_NAME}-backup"

  if docker image inspect "${BACKUP_TAG}-backend:latest" &>/dev/null 2>&1; then
    log_info "백업 이미지로 롤백 중..."
    $DC down --timeout 30
    docker tag "${BACKUP_TAG}-backend:latest" "${PROJECT_NAME}-backend:latest"
    docker tag "${BACKUP_TAG}-frontend:latest" "${PROJECT_NAME}-frontend:latest"
    $DC up -d
    log_success "롤백 완료"
  else
    log_error "백업 이미지가 없습니다. 롤백 불가."
    exit 1
  fi
  exit 0
fi

# ─── 배포 시작 ────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}============================================${NC}"
echo -e "${BOLD}${GREEN}  일일 투자 정보 요약 서비스 배포 시작${NC}"
echo -e "${BOLD}${GREEN}  $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo -e "${BOLD}${GREEN}============================================${NC}"

# ─── 1. Git Pull ──────────────────────────────────────────────────────────────
if [ "$DO_PULL" = true ]; then
  log_step "1. 최신 코드 Pull"
  if [ -d ".git" ]; then
    git pull origin "$(git branch --show-current)"
    log_success "Git pull 완료"
  else
    log_warn ".git 디렉토리 없음 — git pull 건너뜀"
  fi
fi

# ─── 2. 현재 이미지 백업 ──────────────────────────────────────────────────────
log_step "2. 현재 이미지 백업"
for svc in backend frontend; do
  IMAGE_ID=$(docker images -q "${PROJECT_NAME}_${svc}" 2>/dev/null || true)
  if [ -n "$IMAGE_ID" ]; then
    docker tag "$IMAGE_ID" "${PROJECT_NAME}-backup-${svc}:latest" 2>/dev/null || true
    log_info "${svc} 이미지 백업 완료"
  fi
done

# ─── 3. Docker 이미지 빌드 ────────────────────────────────────────────────────
log_step "3. Docker 이미지 빌드"

BUILD_ARGS=""
[ "$NO_CACHE" = true ] && BUILD_ARGS="--no-cache" && log_warn "캐시 없이 빌드합니다 (시간이 오래 걸릴 수 있습니다)"

$DC build $BUILD_ARGS

log_success "이미지 빌드 완료"

# ─── 4. 빌드 전용 모드 종료 ───────────────────────────────────────────────────
if [ "$BUILD_ONLY" = true ]; then
  log_success "빌드 전용 모드 완료 (컨테이너 재시작 없음)"
  exit 0
fi

# ─── 5. 컨테이너 재시작 ───────────────────────────────────────────────────────
log_step "4. 컨테이너 재시작"
$DC down --timeout 30
log_info "기존 컨테이너 중지 완료"

$DC up -d
log_success "컨테이너 시작 완료"

# ─── 6. 헬스체크 대기 ────────────────────────────────────────────────────────
log_step "5. 서비스 헬스체크"

wait_healthy() {
  local container=$1
  local service_name=$2
  local elapsed=0

  echo -n "  ⏳ ${service_name} 기동 대기 중"

  while [ $elapsed -lt $HEALTH_TIMEOUT ]; do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$container" 2>/dev/null || echo "not_found")

    case $STATUS in
      healthy)
        echo -e "\n  ${GREEN}✅ ${service_name} 정상 기동 (${elapsed}초)${NC}"
        return 0 ;;
      unhealthy)
        echo -e "\n  ${RED}❌ ${service_name} 헬스체크 실패${NC}"
        docker logs "$container" --tail 30
        return 1 ;;
      starting|not_found)
        echo -n "."
        sleep $HEALTH_INTERVAL
        elapsed=$((elapsed + HEALTH_INTERVAL)) ;;
      *)
        echo -e "\n  ${YELLOW}⚠️  헬스체크 없음 — 상태: $STATUS${NC}"
        return 0 ;;
    esac
  done

  echo -e "\n  ${RED}❌ ${service_name} 헬스체크 타임아웃 (${HEALTH_TIMEOUT}초)${NC}"
  return 1
}

FAILED=0
wait_healthy "investment-postgres" "PostgreSQL"  || FAILED=1
wait_healthy "investment-backend"  "Backend"     || FAILED=1
wait_healthy "investment-frontend" "Frontend"    || FAILED=1

# ─── 7. 배포 결과 요약 ────────────────────────────────────────────────────────
log_step "6. 배포 결과"

echo ""
echo -e "${BOLD}  컨테이너 상태:${NC}"
$DC ps

echo ""

if [ $FAILED -eq 0 ]; then
  echo -e "${BOLD}${GREEN}============================================${NC}"
  echo -e "${BOLD}${GREEN}  ✅ 배포 성공!${NC}"
  echo -e "${BOLD}${GREEN}============================================${NC}"
  echo -e "  ${CYAN}Frontend:${NC} http://localhost"
  echo -e "  ${CYAN}Backend:${NC}  http://localhost:8080"
  echo -e "  ${CYAN}Health:${NC}   http://localhost:8080/actuator/health"
  echo -e "  ${CYAN}API:${NC}      http://localhost:8080/api/v1/summaries?date=$(date '+%Y-%m-%d')"
  echo ""
else
  echo -e "${BOLD}${RED}============================================${NC}"
  echo -e "${BOLD}${RED}  ❌ 배포 실패 — 로그를 확인하세요${NC}"
  echo -e "${BOLD}${RED}============================================${NC}"
  echo ""
  echo "  로그 확인:"
  echo "    docker logs investment-backend  --tail 50"
  echo "    docker logs investment-frontend --tail 50"
  echo ""
  echo "  롤백:"
  echo "    ./deploy.sh --rollback"
  exit 1
fi
