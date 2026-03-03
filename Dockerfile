FROM ghcr.io/cirruslabs/flutter:latest as build

WORKDIR /app
COPY . .
RUN flutter clean
RUN flutter pub get
RUN flutter build web  --release --dart-define=API_BASE_URL=https://university-journal-back-1.onrender.com

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

RUN echo "server { listen 80; location / { root /usr/share/nginx/html; try_files \$uri \$uri/ /index.html; } }" > /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]