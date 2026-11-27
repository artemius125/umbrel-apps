#!/usr/bin/env bash
# Режим B: сервер без экрана (Umbrel). Xvfb внутри контейнера, software-GL, CDP наружу через socat.
# Запускать НА хосте (Umbrel), не с твоего ПК.
set -euo pipefail

NAME="${NAME:-agent-hands}"
IMAGE="${IMAGE:-agent-hands:chrome}"
DIR="${DIR:-$(cd "$(dirname "$0")" && pwd)}"
CDP_RELAY_PORT="${CDP_RELAY_PORT:-9223}"

mkdir -p "$DIR/profile"
# профиль должен принадлежать uid 1000 (пользователь ubuntu в контейнере)
chown -R 1000:1000 "$DIR/profile" 2>/dev/null || true
rm -f "$DIR/profile"/Singleton* 2>/dev/null || true

sudo docker rm -f "$NAME" >/dev/null 2>&1 || true

sudo docker run -d --name "$NAME" \
  --restart unless-stopped \
  --network host \
  --shm-size=1g \
  -e CDP_RELAY_PORT="$CDP_RELAY_PORT" \
  -e XVFB_SCREEN="${XVFB_SCREEN:-1920x1080x24}" \
  -v "$DIR/profile:/profile" \
  "$IMAGE" >/dev/null

echo "$NAME запущен, CDP: http://127.0.0.1:${CDP_RELAY_PORT}"
