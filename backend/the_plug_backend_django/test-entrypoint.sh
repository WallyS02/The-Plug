#!/bin/bash

python3 manage.py makemigrations api --settings=the_plug_backend_django.e2e_test_settings
python3 manage.py migrate --settings=the_plug_backend_django.e2e_test_settings
python3 manage.py loaddata api/fixtures/herbs.json --settings=the_plug_backend_django.e2e_test_settings
python3 manage.py runserver 0.0.0.0:8080 --settings=the_plug_backend_django.e2e_test_settings