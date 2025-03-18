#!/bin/bash -i
source ~/.bashrc
if [ "$(minikube status | grep "host: Running")" != "host: Running" ];
then
  chmod +x ./set-up-cluster.sh
  ./set-up-cluster.sh
fi
cd namespaces
k apply -f plug-namespace.yaml
cd ../storage-classes
k apply -f db-storage-class.yaml
cd ../pvces
k apply -f db-pvc.yaml
cd ../secrets
k apply -f db-secret.yaml
cd ../stateful-sets
k apply -f db-stateful-set.yaml
cd ../services
k apply -f db-service.yaml
cd ../secrets
k apply -f pgadmin-secret.yaml
cd ../deployments
k apply -f pgadmin-deployment.yaml
cd ../services
k apply -f pgadmin-service.yaml
cd ../config-maps
k apply -f backend-config-map.yaml
cd ../secrets
k apply -f backend-secret.yaml
cd ../deployments
k apply -f backend-deployment.yaml
cd ../services
k apply -f backend-service.yaml
cd ../network-policies
k apply -f backend-db-network-policy.yaml
cd ../deployments
k apply -f frontend-deployment.yaml
cd ../services
k apply -f frontend-service.yaml
cd ../network-policies
k apply -f frontend-backend-network-policy.yaml
cd ../ingresses
k apply -f ingress.yaml
cd ..
minikube tunnel
