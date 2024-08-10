FROM python:3.11-alpine
WORKDIR /app

LABEL org.opencontainers.image.title="the-plug-backend"
LABEL org.opencontainers.image.authors="Sebastian (WallyS) Kutny"
LABEL org.opencontainers.image.source="https://github.com/WallyS02/The-Plug"
LABEL org.opencontainers.image.url="https://github.com/WallyS02/The-Plug"
LABEL org.opencontainers.image.vendor="Sebastian (WallyS) Kutny"
LABEL org.opencontainers.image.version="0.0.1"
LABEL org.opencontainers.image.description="The Plug backend"
#LABEL org.opencontainers.image.licenses="MIT"

ENV VERSION="0.0.1"

COPY backend/the_plug_backend_django/requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/the_plug_backend_django/. /app

ENV DB_NAME=${POSTGRES_DB}
ENV DB_USER=${POSTGRES_USER}
ENV DB_PASSWORD=${POSTGRES_PASSWORD}
ENV DB_HOST=${DB_HOST}
ENV WEB_APP_URL="http://localhost"

EXPOSE 8080

ENTRYPOINT ["python3"]
CMD ["manage.py", "runserver", "0.0.0.0:8080"]
