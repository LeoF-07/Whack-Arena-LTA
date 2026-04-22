# --- Stage 1: Build ---
FROM dart:stable AS build

WORKDIR /app

# Copia pubspec e scarica dipendenze
COPY pubspec.* ./
RUN dart pub get

# Copia il resto del progetto
COPY . .

# Compila in un eseguibile nativo
RUN dart compile exe bin/server.dart -o /app/server

# --- Stage 2: Runtime ---
FROM debian:stable-slim

# Installiamo solo ciò che serve per eseguire l'app
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia l'eseguibile dal primo stage
COPY --from=build /app/server /app/server

EXPOSE 8080

CMD ["./server"]