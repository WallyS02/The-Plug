FROM python:3.11-alpine AS builder

WORKDIR /app

# COPY backend/the_plug_backend_django/requirements.txt /app
COPY requirements.txt /app
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.11-alpine

WORKDIR /app

LABEL org.opencontainers.image.title="the-plug-backend"
LABEL org.opencontainers.image.authors="Sebastian (WallyS) Kutny"
LABEL org.opencontainers.image.source="https://github.com/WallyS02/The-Plug"
LABEL org.opencontainers.image.url="https://github.com/WallyS02/The-Plug"
LABEL org.opencontainers.image.vendor="Sebastian (WallyS) Kutny"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.description="The Plug backend"
LABEL org.opencontainers.image.licenses="MIT"

ENV VERSION="1.0.0"

COPY --from=builder /install /usr/local
# COPY backend/the_plug_backend_django/. /app
COPY . /app

ENV DB_NAME=${POSTGRES_DB}
ENV DB_USER=${POSTGRES_USER}
ENV DB_PASSWORD=${POSTGRES_PASSWORD}
ENV DB_HOST=${DB_HOST}
ENV EMAIL_HOST_USER=${EMAIL_HOST_USER}
ENV EMAIL_HOST_PASSWORD=${EMAIL_HOST_PASSWORD}
ENV WEB_APP_URL="http://localhost"
ENV ALLOWED_HOSTS="*"
ENV DEBUG=1
ENV SECRET_KEY=${SECRET_KEY}

RUN addgroup -S user && adduser -S user -G user
USER user

EXPOSE 8080

ENTRYPOINT ["python3"]
CMD ["manage.py", "runserver", "0.0.0.0:8080"]
