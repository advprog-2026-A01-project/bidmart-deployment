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
    if curl -fsS "$url" >/dev/null 2>&1; then
      echo "OK: $name is reachable."
      return 0
    fi

    echo "Attempt $attempt/$max_attempts: $name belum siap..."
    sleep 2
  done

  echo "ERROR: $name is not reachable after $max_attempts attempts."
  return 1
}

wait_http "$GATEWAY_URL/actuator/health" "API Gateway health"
wait_http "$FRONTEND_URL" "Frontend"

echo "==> Running Gateway/Auth HTTP smoke test"
GATEWAY_URL="$GATEWAY_URL" ../bidmart-api-gateway/scripts/smoke-auth-gateway.sh

echo "==> Running Gateway/Auth gRPC smoke test"
GATEWAY_URL="$GATEWAY_URL" ../bidmart-api-gateway/scripts/smoke-auth-grpc.sh

echo "==> Docker Compose smoke test passed"
