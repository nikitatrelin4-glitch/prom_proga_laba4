# Стадия 1: Сборка приложения
FROM ubuntu:latest AS builder

# Отключаем интерактивные диалоги apt
ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем необходимые инструменты сборки и библиотеку OpenSSL
RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    g++ \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Копируем исходный код
COPY . .

# Собираем проект
RUN cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
    && cmake --build build

# Стадия 2: Финальный легковесный образ для запуска
FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем curl для health-check и саму libssl3, которая требовалась приложению
RUN apt-get update && apt-get install -y \
    libssl3 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Копируем только готовый исполняемый файл из первой стадии
COPY --from=builder /app/build/app .

# Если приложению нужны статические файлы (например, папка html, public или config), 
# раскомментируй строку ниже, заменив "public" на твою папку:
# COPY --from=builder /app/public ./public

EXPOSE 8080

CMD ["./app"]
