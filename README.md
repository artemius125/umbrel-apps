# umbrel-apps

Community app store для Umbrel. Сейчас в нём одно приложение — **Agent Hands**: настоящий Google Chrome, которым агент управляет по Chrome DevTools Protocol.

## Установка

1. Umbrel → App Store → Community App Stores → добавить магазин:

   ```
   https://github.com/artemius125/umbrel-apps.git
   ```

2. В магазине появится **Agent Hands** → Install.

После установки:

| Что | Где |
|---|---|
| Страница приложения | `http://<umbrel>:8080/` |
| CDP-эндпоинт | `http://<umbrel>:9223/json/version` |
| Профиль браузера | `<app-data>/agent-hands/data` |

## Что внутри приложения

- Google Chrome 158, запуск **без** `--headless` и `--enable-automation`.
- Xvfb 1920×1080: у Umbrel нет ни GPU, ни экрана, поэтому WebGL программный (`llvmpipe`).
- Постоянный профиль: cookies, история, логины переживают перезапуск.
- Локаль `ru-RU`, таймзона `Europe/Moscow`.
- Лимиты: 2 CPU, 2 ГБ RAM.

## Исходники образа

`container/` — Dockerfile и скрипты запуска. Сборка:

```bash
cd container
docker build -t agent-hands:chrome .
```

Образ в манифесте приложения указывает на локальный registry (`192.168.0.81:5000`), потому что образ нигде не опубликован. Если планируешь ставить приложение на чужую Umbrel — собери образ и запушь его в доступный registry, затем обнови `agent-hands/docker-compose.yml`.

## Обновление приложения

1. Правь файлы, поднимай `version` в `agent-hands/umbrel-app.yml`.
2. Коммить и пуш в этот репозиторий.
3. В Umbrel: App Store → обновить магазин → Update у приложения.

## Ограничения

- CDP слушает `0.0.0.0:9223` без авторизации: любой в локальной сети может управлять браузером. Закрывай файрволом или ходи через SSH-туннель.
- Программный рендер (`llvmpipe`) и отсутствие медиаустройств — заметные признаки «сервера, а не десктопа». Для боевых сценариев руки лучше держать на машине с GPU.
