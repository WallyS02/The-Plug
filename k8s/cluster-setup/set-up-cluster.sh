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

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
kubectl create namespace monitoring
helm install prometheus prometheus-community/prometheus --namespace monitoring
helm install grafana grafana/grafana --namespace monitoring

k apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.12.0/deploy/static/provider/cloud/deploy.yaml

helm repo update

set -o allexport
source ../raw/secrets/.env
set +o allexport
envsubst < ../raw/secrets/backend-secret.yaml > ../raw/secrets/backend-secret-resolved.yaml
envsubst < ../raw/secrets/db-secret.yaml > ../raw/secrets/db-secret-resolved.yaml
envsubst < ../raw/secrets/pgadmin-secret.yaml > ../raw/secrets/pgadmin-secret-resolved.yaml

chmod +x ./build-images.sh
./build-images.sh