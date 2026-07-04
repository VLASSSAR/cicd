# Берем готовый Docker-образ с Go 1.26 и Alpine Linux
FROM golang:1.26-alpine AS builder

# Создаёт рабочую директорию /src внутри контейнера и делает её текущей
WORKDIR /src

# Копируем файлы модуля отдельно, чтобы Docker мог кешировать скачивание зависимостей
COPY go.mod ./

# Скачиваем зависимости
RUN go mod download

# Копируем весь проект в /src
COPY . .

# Собираем Go-приложение
RUN CGO_ENABLED=0 GOOS=linux \
    go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /app \
    ./cmd/app

# Финальный минимальный образ
FROM alpine:3.23

# Создаём непривилегированного пользователя
RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

# Копируем готовый бинарник из builder-стадии
COPY --from=builder /app /app

# Запускаем приложение не от root
USER appuser

# Документируем порт приложения
EXPOSE 8080

# Команда запуска контейнера
ENTRYPOINT ["/app"]