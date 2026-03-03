FROM ghcr.io/cirruslabs/flutter:stable AS build

ARG API_BASE_URL

WORKDIR /app
COPY . .

RUN flutter clean
RUN flutter pub get

RUN flutter build web --release --web-renderer=canvaskit --dart-define=API_BASE_URL=$API_BASE_URL

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

RUN echo "server { listen 80; location / { root /usr/share/nginx/html; try_files \$uri \$uri/ /index.html; } }" > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
