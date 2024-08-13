#! /bin/bash

sleep 10
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py loaddata api/fixtures/drugs.json