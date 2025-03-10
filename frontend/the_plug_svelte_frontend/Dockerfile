FROM node:18-alpine AS builder

WORKDIR /app

RUN apk add --no-cache \
    autoconf \
    automake \
    g++ \
    libpng-dev \
    libtool \
    make \
    nasm \
    python3 \
    zlib-dev

#COPY frontend/the_plug_svelte_frontend/package.json frontend/the_plug_svelte_frontend/package-lock.json ./
COPY package.json package-lock.json ./

RUN npm install

#COPY frontend/the_plug_svelte_frontend/. .
COPY . .

RUN npm run build

FROM bitnami/nginx:1.27.4

LABEL org.opencontainers.image.title="the-plug-frontend"
LABEL org.opencontainers.image.authors="Sebastian (WallyS) Kutny"
LABEL org.opencontainers.image.source="https://github.com/WallyS02/The-Plug"
LABEL org.opencontainers.image.url="https://github.com/WallyS02/The-Plug"
LABEL org.opencontainers.image.vendor="Sebastian (WallyS) Kutny"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.description="The Plug frontend"
LABEL org.opencontainers.image.licenses="MIT"

ENV VERSION="1.0.0"

ENV NGINX_ENVSUBST_OUTPUT_DIR=/opt/bitnami/nginx/conf

#COPY frontend/the_plug_svelte_frontend/docker/etc/nginx/configs/ /etc/nginx/configs/
COPY docker/etc/nginx/configs/ /opt/bitnami/nginx/conf/server_blocks/

COPY --from=builder /app/dist /app

EXPOSE 8080