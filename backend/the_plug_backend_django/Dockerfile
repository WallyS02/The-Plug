FROM python:3.11-alpine
WORKDIR /app

COPY backend/the_plug_backend_django/requirements.txt /app
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/the_plug_backend_django/. /app

ENV NAME="postgres"
ENV USER="admin"
ENV PASSWORD="admin"
ENV HOST="127.0.0.1"
ENV WEB_APP_URL="http://localhost"

EXPOSE 8080

ENTRYPOINT ["python3"]
CMD ["manage.py", "runserver", "0.0.0.0:8080"]
