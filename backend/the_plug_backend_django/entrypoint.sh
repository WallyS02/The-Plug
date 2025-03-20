#!/bin/bash

sleep 10
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py loaddata api/fixtures/drugs.json
sleep 5
python3 manage.py runserver 0.0.0.0:8080