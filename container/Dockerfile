# «Руки» агента: настоящий Chrome в контейнере.
# Режим A (машина с GPU/X11/звуком): берём всё железо хоста — отпечаток как у обычного десктопа.
# Режим B (сервер без экрана, Umbrel): Xvfb + software-GL — работает, но отпечаток хуже.
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg wget locales tzdata dumb-init socat xvfb \
      libpulse0 libasound2t64 \
      libx11-6 libx11-xcb1 libxcb1 libxcomposite1 libxdamage1 libxext6 \
      libxfixes3 libxrandr2 libxkbcommon0 libxss1 libxtst6 libcups2 libdrm2 \
      libgbm1 libnss3 libnspr4 libatk1.0-0t64 libatk-bridge2.0-0t64 \
      libpango-1.0-0 libcairo2 libcairo-gobject2 libgtk-3-0t64 \
      libglvnd0 libgl1 libglx0 libegl1 libgles2 libvulkan1 libgl1-mesa-dri libglx-mesa0 \
      fonts-liberation fonts-dejavu-core fonts-noto-color-emoji fonts-noto-core \
      x11-utils xauth pulseaudio-utils mesa-utils gosu \
    && rm -rf /var/lib/apt/lists/*

# русская локаль — чтобы Accept-Language и navigator.language были ru-RU
RUN sed -i 's/^# *\(ru_RU.UTF-8\)/\1/' /etc/locale.gen && locale-gen
ENV LANG=ru_RU.UTF-8 LANGUAGE=ru_RU:ru LC_ALL=ru_RU.UTF-8 TZ=Europe/Moscow

# настоящий Google Chrome (не Chromium, не Chrome for Testing)
RUN curl -fsSL -o /tmp/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get update \
    && apt-get install -y --no-install-recommends /tmp/chrome.deb \
    && rm -f /tmp/chrome.deb \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

WORKDIR /home/ubuntu
# entrypoint стартует от root: чинит права на /profile и сбрасывает stale-локи,
# затем перезапускает себя от пользователя ubuntu (uid 1000).

ENV DISPLAY=:0 \
    PULSE_SERVER=unix:/run/user/1000/pulse/native \
    XDG_RUNTIME_DIR=/run/user/1000

EXPOSE 9222

# Важно: никаких --enable-automation и --headless. Только отладочный порт,
# постоянный профиль и обычное поведение окна.
ENTRYPOINT ["/usr/bin/dumb-init", "--", "/entrypoint.sh"]
CMD ["--no-sandbox", \
     "--remote-debugging-port=9222", \
     "--remote-debugging-address=127.0.0.1", \
     "--user-data-dir=/profile", \
     "--no-first-run", \
     "--no-default-browser-check", \
     "--window-size=1920,1080", \
     "--window-position=0,0", \
     "--ozone-platform=x11", \
     "--use-gl=angle", \
     "--use-angle=gl", \
     "--ignore-gpu-blocklist", \
     "--disable-dev-shm-usage", \
     "--disable-features=TranslateUI,MediaRouter", \
     "about:blank"]
