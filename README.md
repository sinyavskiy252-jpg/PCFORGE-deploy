# PCFORGE — deploy

Репозиторий содержит конфигурацию развёртывания основного React-приложения PCFORGE.

## Состав

- `Dockerfile` — сборка React-приложения и подготовка образа Nginx.
- `compose.yaml` — запуск контейнера, публикация портов 8080 и 8443, передача Firebase-параметров и healthcheck.
- `nginx.conf` — HTTPS, перенаправление HTTP, SPA fallback, заголовки безопасности и gzip.
- `.github/workflows/deploy-check.yml` — проверка Compose и сборка Docker-образа; при push в main публикация в GHCR.
- `certs/` — локальные сертификат и закрытый ключ. В Git хранится только `.gitkeep`.

## Локальный запуск

Из общей папки, где рядом находятся `PCsait` и `PCFORGE-deploy`:

```powershell
docker compose --env-file PCsait/.env -f PCFORGE-deploy/compose.yaml up --build -d
docker compose -f PCFORGE-deploy/compose.yaml ps
docker compose -f PCFORGE-deploy/compose.yaml logs
```

Сайт: `https://pcforge.localhost:8443`. Остановка:

```powershell
docker compose -f PCFORGE-deploy/compose.yaml down
```

## Переменные Firebase для GitHub Actions

В этом репозитории открой **Settings → Secrets and variables → Actions** и добавь шесть repository secrets:

- `VITE_FIREBASE_API_KEY`
- `VITE_FIREBASE_AUTH_DOMAIN`
- `VITE_FIREBASE_PROJECT_ID`
- `VITE_FIREBASE_STORAGE_BUCKET`
- `VITE_FIREBASE_MESSAGING_SENDER_ID`
- `VITE_FIREBASE_APP_ID`

Значения возьми из локального `PCsait/.env` — только текст после знака `=`. Workflow создаёт временный `PCsait/.env` и использует значения при сборке Docker-образа. Локальный `.env` не отправляется в репозиторий.

Значения `VITE_*` являются публичной конфигурацией Firebase Web SDK и попадут в браузерную сборку. Они не являются секретами сервисного аккаунта. Не добавляй в них service-account JSON, приватные ключи или пароли.

Для публикации в GHCR используется встроенный `GITHUB_TOKEN` с разрешением `packages: write`; отдельный пароль GHCR не нужен.

## Сертификаты

Файлы `pcforge.localhost.pem` и `pcforge.localhost-key.pem` нужны только для локального HTTPS. Не загружай их в GitHub. Если они отсутствуют, создай их командой OpenSSL из папки проекта:

```powershell
New-Item -ItemType Directory -Force .\PCFORGE-deploy\certs
openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 365 -keyout .\PCFORGE-deploy\certs\pcforge.localhost-key.pem -out .\PCFORGE-deploy\certs\pcforge.localhost.pem -subj "/CN=pcforge.localhost" -addext "subjectAltName=DNS:pcforge.localhost,DNS:localhost,IP:127.0.0.1"
```

## Связанный репозиторий

Исходный код сайта: https://github.com/sinyavskiy252-jpg/PCsait
