#!/bin/bash

sleep 10
python3 manage.py makemigrations api
python3 manage.py migrate
python3 manage.py loaddata api/fixtures/herbs.json
sleep 5
python3 manage.py runserver 0.0.0.0:8080