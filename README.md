# PCFORGE — deploy

Репозиторий содержит конфигурацию развёртывания основного React-приложения PCFORGE.

## Состав
- Dockerfile — сборка React-приложения и подготовка образа Nginx.
- compose.yaml — запуск контейнера, порты 8080 и 8443, передача Firebase-переменных.
- nginx.conf — раздача статических файлов, HTTPS и перенаправление HTTP на HTTPS.
- .github/workflows/ — автоматическая проверка конфигурации.
- certs/ — локальные TLS-сертификат и приватный ключ. Сами сертификаты не хранятся в Git.

## Как устроена папка certs

В репозитории хранится только файл .gitkeep, чтобы Git сохранял пустую папку. Файлы pcforge.localhost.pem и pcforge.localhost-key.pem нужно создать локально. Не загружайте приватный ключ в GitHub.

## Создание локального сертификата

Из общей папки, где рядом находятся PCsait и PCFORGE-deploy, выполните команду в терминале с установленным OpenSSL:

```powershell
New-Item -ItemType Directory -Force .\PCFORGE-deploy\certs
openssl req -x509 -nodes -newkey rsa:2048 -sha256 -days 365 -keyout .\PCFORGE-deploy\certs\pcforge.localhost-key.pem -out .\PCFORGE-deploy\certs\pcforge.localhost.pem -subj "/CN=pcforge.localhost" -addext "subjectAltName=DNS:pcforge.localhost,DNS:localhost,IP:127.0.0.1"
```

## Запуск

Команда выполняется из общей папки проекта:

```powershell
docker compose --env-file PCsait/.env -f PCFORGE-deploy/compose.yaml up --build -d
```

Сайт открывается по адресу https://localhost:8443. Самоподписанный сертификат может вызвать предупреждение браузера — это ожидаемо для локального стенда.

Остановка:
```powershell
docker compose -f PCFORGE-deploy/compose.yaml down
```

## Связанный репозиторий

Исходный код сайта находится в [PCsait](https://github.com/sinyavskiy252-jpg/PCsait).

## Обновление образа после изменений Frontend

Основной исходный код находится в отдельном репозитории [PCsait](https://github.com/sinyavskiy252-jpg/PCsait). Изменение Frontend само по себе не запускает workflow этого репозитория. После слияния изменений в `PCsait/main` запусти workflow **PCFORGE deployment check** вручную во вкладке Actions или создай небольшой коммит в этом репозитории. Workflow повторно получает актуальный `PCsait/main`, проверяет Compose, собирает Docker-образ и публикует его в GHCR.
