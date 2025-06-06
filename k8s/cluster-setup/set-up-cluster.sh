#!/bin/bash -i
source ~/.bashrc
minikube start

docker run -d --privileged --name nfs-server  -v /var/nfs:/var/nfs  phico/nfs-server:latest
docker network connect minikube nfs-server
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm repo update
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=nfs-server \
    --set nfs.path=/var/nfs

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --create-namespace --values ./ingress-nginx/values.yml

set -o allexport
source ../raw/secrets/.env
set +o allexport
envsubst < ../raw/secrets/backend-secret.yaml > ../raw/secrets/backend-secret-resolved.yaml
envsubst < ../raw/secrets/db-secret.yaml > ../raw/secrets/db-secret-resolved.yaml
envsubst < ../raw/secrets/pgadmin-secret.yaml > ../raw/secrets/pgadmin-secret-resolved.yaml

minikube addons enable metrics-server

for file in ./monitoring/grafana/dashboards/*; do kubectl apply --server-side=true -f $file; done

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
kubectl apply -f ../raw/secrets/db-secret-resolved.yaml --namespace monitoring
helm upgrade --install loki grafana/loki --namespace monitoring --values ./monitoring/loki/values.yml
helm upgrade --install alloy grafana/alloy --namespace monitoring --values ./monitoring/loki/alloy.yml
helm upgrade --install prometheus-grafana prometheus-community/kube-prometheus-stack --namespace monitoring --values ./monitoring/prometheus/values.yml
for file in ./monitoring/prometheus/alerts/*; do kubectl apply -f $file; done
helm upgrade --install blackbox-exporter prometheus-community/prometheus-blackbox-exporter --namespace monitoring --values ./monitoring/exporters/blackbox-exporter/blackbox-values.yml
helm upgrade --install pg-exporter prometheus-community/prometheus-postgres-exporter --namespace monitoring --values ./monitoring/exporters/pg-exporter/pg-values.yml
helm upgrade --install nginx-exporter prometheus-community/prometheus-nginx-exporter --namespace monitoring --values ./monitoring/exporters/nginx-exporter/nginx-values.yml
kubectl apply -f ./monitoring/exporters/django/backend-service-monitor.yml

helm repo add sloth https://slok.github.io/sloth
helm repo update
helm upgrade --install sloth sloth/sloth --namespace monitoring
for file in ./monitoring/prometheus/slos/*; do kubectl apply -f $file; done

chmod +x ./build-images.sh
./build-images.sh