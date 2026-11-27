#!/usr/bin/env bash
# Поднимает «руки» агента: настоящий Chrome в контейнере, с GPU, звуком и X11 хоста.
set -euo pipefail

NAME="${NAME:-agent-hands}"
IMAGE="${IMAGE:-agent-hands:chrome}"
PROFILE="${PROFILE:-$(dirname "$0")/profile}"
PORT="${PORT:-9222}"

mkdir -p "$PROFILE"

docker rm -f "$NAME" >/dev/null 2>&1 || true

exec docker run -d --name "$NAME" \
  --gpus all \
  --network host \
  --shm-size=1g \
  -e NVIDIA_DRIVER_CAPABILITIES=all \
  -e DISPLAY="${DISPLAY:-:0}" \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "${HOME}/.Xauthority:/home/ubuntu/.Xauthority:ro" \
  -v /run/user/1000/pulse:/run/user/1000/pulse \
  -v /usr/share/fonts:/usr/share/fonts:ro \
  -v "${HOME}/.local/share/fonts:/home/artem/.local/share/fonts:ro" \
  -v "${HOME}/.fonts:/home/artem/.fonts:ro" \
  -v "${PROFILE}:/profile" \
  "$IMAGE" >/dev/null
