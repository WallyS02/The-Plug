#!/bin/bash -i
source ~/.bashrc
if ! minikube status | grep -q "host: Running";
then
  chmod +x ./set-up-cluster.sh
  ./set-up-cluster.sh
fi
kubectl apply -f ../raw/namespaces/plug-namespace.yaml
kubectl apply -f ../raw/storage-classes/db-storage-class.yaml
kubectl apply -f ../raw/pvces/db-pvc.yaml
kubectl apply -f ../raw/secrets/db-secret-resolved.yaml --namespace plug-namespace
kubectl apply -f ../raw/stateful-sets/db-stateful-set.yaml
kubectl apply -f ../raw/services/db-service.yaml
kubectl apply -f ../raw/secrets/pgadmin-secret-resolved.yaml
kubectl apply -f ../raw/hpas/db-hpa.yaml
kubectl apply -f ../raw/deployments/pgadmin-deployment.yaml
kubectl apply -f ../raw/services/pgadmin-service.yaml
kubectl apply -f ../raw/config-maps/backend-config-map.yaml
kubectl apply -f ../raw/secrets/backend-secret-resolved.yaml
kubectl apply -f ../raw/deployments/backend-deployment.yaml
kubectl apply -f ../raw/services/backend-service.yaml
kubectl apply -f ../raw/hpas/backend-hpa.yaml
kubectl apply -f ../raw/network-policies/backend-db-network-policy.yaml
kubectl apply -f ../raw/deployments/frontend-deployment.yaml
kubectl apply -f ../raw/services/frontend-service.yaml
kubectl apply -f ../raw/hpas/frontend-hpa.yaml
kubectl apply -f ../raw/network-policies/frontend-backend-network-policy.yaml
kubectl apply -f ../raw/ingresses/ingress.yaml
kubectl config set-context --current --namespace=plug-namespace
# minikube tunnel # command asks for password for permissions
