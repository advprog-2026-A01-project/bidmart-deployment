#!/usr/bin/env bash
set -euo pipefail

COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"
GATEWAY_URL="${GATEWAY_URL:-http://localhost:8080}"
FRONTEND_URL="${FRONTEND_URL:-http://localhost:5173}"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "ERROR: $COMPOSE_FILE is missing."
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq belum terinstall. Jalankan: sudo apt install -y jq"
  exit 1
fi

wait_http() {
  local url="$1"
  local name="$2"
  local max_attempts="${3:-60}"

  echo "==> Waiting for $name at $url"

  for attempt in $(seq 1 "$max_attempts"); do
    if curl -fsS "$url" >/tmp/bidmart-smoke-response.txt 2>/tmp/bidmart-smoke-error.txt; then
      echo "OK: $name is reachable."
      return 0
    fi

    echo "Attempt $attempt/$max_attempts: $name belum siap..."
    sleep 2
  done

  echo "ERROR: $name is not reachable after $max_attempts attempts."
  echo "Last curl stderr:"
  cat /tmp/bidmart-smoke-error.txt || true
  echo "Last response:"
  cat /tmp/bidmart-smoke-response.txt || true
  return 1
}

wait_captcha_payload() {
  local max_attempts="${1:-60}"

  echo "==> Waiting for captcha endpoint to return captchaId and devAnswer"

  for attempt in $(seq 1 "$max_attempts"); do
    local response
    response="$(curl -fsS "$GATEWAY_URL/api/auth/captcha" 2>/dev/null || true)"

    local captcha_id
    local dev_answer
    captcha_id="$(echo "$response" | jq -r '.captchaId // empty' 2>/dev/null || true)"
    dev_answer="$(echo "$response" | jq -r '.devAnswer // empty' 2>/dev/null || true)"

    if [[ -n "$captcha_id" && -n "$dev_answer" ]]; then
      echo "OK: captcha endpoint is ready."
      return 0
    fi

    echo "Attempt $attempt/$max_attempts: captcha endpoint belum siap..."
    sleep 2
  done

  echo "ERROR: captcha endpoint did not return captchaId/devAnswer."
  return 1
}

wait_http "$GATEWAY_URL/actuator/health" "API Gateway health" 90
wait_http "$FRONTEND_URL" "Frontend" 90

# GitHub Actions can be slower than local Docker, so wait for the real
# Gateway -> Auth Service -> Auth DB path before running the full smoke script.
wait_http "$GATEWAY_URL/api/db/ping" "Auth DB ping through Gateway" 90
wait_captcha_payload 90

# Also wait for the internal gRPC path before the final smoke run.
wait_http "$GATEWAY_URL/api/gateway/internal/auth-grpc/status" "Gateway/Auth gRPC diagnostic endpoint" 90

echo "==> Running Gateway/Auth HTTP smoke test"
GATEWAY_URL="$GATEWAY_URL" ../bidmart-api-gateway/scripts/smoke-auth-gateway.sh

echo "==> Running Gateway/Auth gRPC smoke test"
GATEWAY_URL="$GATEWAY_URL" ../bidmart-api-gateway/scripts/smoke-auth-grpc.sh

echo "==> Docker Compose smoke test passed"
