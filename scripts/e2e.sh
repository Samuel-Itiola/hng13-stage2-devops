#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

PUBLIC_IP=${PUBLIC_IP:-$(curl -s ifconfig.me || echo "127.0.0.1")}
MAIN_PORT=${PUBLIC_PORT:-8080}
BLUE_PORT=${BLUE_PORT:-8081}
GREEN_PORT=${GREEN_PORT:-8082}

echo "[e2e] Building images..."
docker compose build --pull

echo "[e2e] Starting stack..."
docker compose up -d

echo "[e2e] Waiting for services to be ready..."
deadline=$((SECONDS+60))
until curl -fsS "http://127.0.0.1:${MAIN_PORT}/version" >/dev/null 2>&1; do
  if (( SECONDS > deadline )); then
    echo "[e2e] Timeout waiting for NGINX" >&2
    docker compose ps
    exit 1
  fi
  sleep 1
done

until curl -fsS "http://127.0.0.1:${BLUE_PORT}/version" >/dev/null 2>&1; do sleep 1; done
until curl -fsS "http://127.0.0.1:${GREEN_PORT}/version" >/dev/null 2>&1; do sleep 1; done

echo "[e2e] Validating baseline responses..."
main_json=$(curl -fsS "http://127.0.0.1:${MAIN_PORT}/version")
blue_json=$(curl -fsS "http://127.0.0.1:${BLUE_PORT}/version")
green_json=$(curl -fsS "http://127.0.0.1:${GREEN_PORT}/version")

echo "$main_json" | grep -q '"pool"' || { echo "[e2e] main missing pool"; exit 1; }
echo "$blue_json" | grep -q '"pool":"blue"' || { echo "[e2e] blue not reporting blue"; exit 1; }
echo "$green_json" | grep -q '"pool":"green"' || { echo "[e2e] green not reporting green"; exit 1; }

echo "[e2e] Triggering chaos on blue and checking failover..."
curl -fsS -X POST "http://127.0.0.1:${BLUE_PORT}/chaos/start?mode=error" >/dev/null

# NGINX should route to green now
main_headers=$(curl -fsSI "http://127.0.0.1:${MAIN_PORT}/version")
echo "$main_headers" | grep -q '^X-App-Pool: green' || { echo "[e2e] failover header not green"; exit 1; }

echo "[e2e] Stopping chaos on blue and verifying restore..."
curl -fsS -X POST "http://127.0.0.1:${BLUE_PORT}/chaos/stop" >/dev/null
sleep 1
main_headers=$(curl -fsSI "http://127.0.0.1:${MAIN_PORT}/version")
echo "$main_headers" | grep -q '^X-App-Pool: blue' || { echo "[e2e] restore header not blue"; exit 1; }

echo "[e2e] Public endpoint sanity (if security group open): http://${PUBLIC_IP}:${MAIN_PORT}/version"
curl -sS --max-time 3 "http://${PUBLIC_IP}:${MAIN_PORT}/version" >/dev/null || true

echo "[e2e] PASS"

