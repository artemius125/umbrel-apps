#!/usr/bin/env bash
# Режим 1 (хост с GPU/X11): берём настоящий DISPLAY, GPU, звук и шрифты снаружи.
# Режим 2 (сервер без экрана, например Umbrel): поднимаем Xvfb и software-GL.
set -e

# Первый запуск от root: приводим профиль в порядок и дальше работаем от ubuntu.
if [ "$(id -u)" = "0" ]; then
  mkdir -p /profile
  chown -R 1000:1000 /profile 2>/dev/null || true
  rm -f /profile/SingletonLock /profile/SingletonCookie /profile/SingletonSocket 2>/dev/null || true
  exec gosu ubuntu /entrypoint.sh "$@"
fi

if ! xdpyinfo -display "${DISPLAY:-:0}" >/dev/null 2>&1; then
  # после рестарта контейнера в /tmp остаётся замок от прошлого Xvfb
  rm -f /tmp/.X99-lock /tmp/.X11-unix/X99 2>/dev/null || true
  echo "[entrypoint] нет X — поднимаю Xvfb :99 (${XVFB_SCREEN:-1920x1080x24})"
  Xvfb :99 -screen 0 "${XVFB_SCREEN:-1920x1080x24}" -nolisten tcp -nolisten unix >/tmp/xvfb.log 2>&1 &
  export DISPLAY=:99
  export LIBGL_ALWAYS_SOFTWARE="${LIBGL_ALWAYS_SOFTWARE:-1}"
  for _ in $(seq 1 50); do xdpyinfo -display :99 >/dev/null 2>&1 && break; sleep 0.1; done
  if ! xdpyinfo -display :99 >/dev/null 2>&1; then
    echo "[entrypoint] Xvfb не поднялся:"; cat /tmp/xvfb.log; exit 1
  fi
else
  echo "[entrypoint] использую существующий DISPLAY=${DISPLAY}"
fi

# Chrome слушает CDP только на loopback — наружу выставляем через socat.
if [ -n "${CDP_RELAY_PORT:-}" ]; then
  echo "[entrypoint] CDP relay 0.0.0.0:${CDP_RELAY_PORT} -> 127.0.0.1:9222"
  socat TCP-LISTEN:"${CDP_RELAY_PORT}",fork,reuseaddr TCP:127.0.0.1:9222 >/tmp/socat.log 2>&1 &
fi

exec /usr/bin/google-chrome "$@"
