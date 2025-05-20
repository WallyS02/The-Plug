#!/bin/bash -i
source ~/.bashrc
eval $(minikube -p minikube docker-env)
docker rmi wallys02/the-plug-backend:latest
docker rmi wallys02/the-plug-frontend:latest
cd ..
cd ../backend/the_plug_backend_django
docker build -t wallys02/the-plug-backend:latest .
cd ..
cd ../frontend/the_plug_svelte_frontend
docker build -t wallys02/the-plug-frontend:latest .
cd ..
cd ../k8s/cluster-setup