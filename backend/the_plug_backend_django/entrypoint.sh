#!/bin/bash

sleep 10
python3 manage.py makemigrations api
python3 manage.py migrate
python3 manage.py loaddata api/fixtures/herbs.json
sleep 5
gunicorn the_plug_backend_django.wsgi --bind 0.0.0.0:8080