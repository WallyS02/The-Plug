#!/bin/bash -i
source ~/.bashrc
minikube start
docker run -d --rm --privileged --name nfs-server  -v /var/nfs:/var/nfs  phico/nfs-server:latest
docker network connect minikube nfs-server
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=nfs-server \
    --set nfs.path=/var/nfs
minikube addons enable metrics-server
k apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml
set -o allexport
source ./secrets/.env
set +o allexport
envsubst < ./secrets/backend-secret.yaml > ./secrets/backend-secret-resolved.yaml
envsubst < ./secrets/db-secret.yaml > ./secrets/db-secret-resolved.yaml
envsubst < ./secrets/pgadmin-secret.yaml > ./secrets/pgadmin-secret-resolved.yaml
chmod +x ./build-images.sh
./build-images.sh