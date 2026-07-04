# Берем готовый Docke-образ с golang 1.25 и версией linux alpine
FROM golang:1.26-alpine AS builder

# Создаёт рабочую директорию /src внутри контейнера и делает её текущей.
WORKDIR /src

# Фактически копирует файл в /src/go.mod
COPY go.mod ./
# Скачиваем зависимости во временный контейнер на стадии сборки
RUN go mod download

# Копирует весь проект из build context в текущую директорию контейнера.
COPY cicd .

RUN CGO_ENABLED=0 GOOS=linux \
    go build \
    -trimpath \
    -ldflags="-s -w" \
    -o /app \
    ./cmd/app

FROM alpine:3.23

RUN addgroup -S appgroup && \
    adduser -S appuser -G appgroup

COPY --from=builder /app /app

USER appuser

EXPOSE 8080

ENTRYPOINT ["/app"]