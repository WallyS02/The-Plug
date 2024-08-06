FROM nginx:1.23.3

LABEL org.opencontainers.image.title="the-plug-frontend"
LABEL org.opencontainers.image.authors="Sebastian (WallyS) Kutny"
LABEL org.opencontainers.image.source="https://github.com/WallyS02/The-Plug"
LABEL org.opencontainers.image.url="https://github.com/WallyS02/The-Plug"
LABEL org.opencontainers.image.vendor="Sebastian (WallyS) Kutny"
LABEL org.opencontainers.image.version="0.0.1"
LABEL org.opencontainers.image.description="The Plug frontend"
#LABEL org.opencontainers.image.licenses="MIT"

LABEL build_version=""
LABEL maintainer=""

ENV VERSION="0.0.1"

ENV API_URL http://localhost:8080/api/

EXPOSE 80

ADD dist/magjob-frontend /usr/share/nginx/html/
ADD docker/etc/nginx/templates/ /etc/nginx/templates/
