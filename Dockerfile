# Шаг 1: Сборка Flutter-приложения
FROM ghcr.io/cirruslabs/flutter:latest AS build

WORKDIR /app
COPY . .

RUN flutter clean && flutter pub get && flutter build web

# Шаг 2: nginx
FROM nginx:alpine

COPY --from=build /app/build/web /usr/share/nginx/html/
COPY default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["flutter", "run", "-d", "web-server", "--web-port=3000", "--web-hostname=0.0.0.0", "--no-sound-null-safety"]
