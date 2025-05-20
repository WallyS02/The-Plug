#!/bin/bash -i
source ~/.bashrc
if ! minikube status | grep -q "host: Running";
then
  chmod +x ./set-up-cluster.sh
  ./set-up-cluster.sh
fi
k apply -f ../raw/namespaces/plug-namespace.yaml
k apply -f ../raw/storage-classes/db-storage-class.yaml
k apply -f ../raw/pvces/db-pvc.yaml
k apply -f ../raw/secrets/db-secret-resolved.yaml
k apply -f ../raw/stateful-sets/db-stateful-set.yaml
k apply -f ../raw/services/db-service.yaml
k apply -f ../raw/secrets/pgadmin-secret-resolved.yaml
k apply -f ../raw/hpas/db-hpa.yaml
k apply -f ../raw/deployments/pgadmin-deployment.yaml
k apply -f ../raw/services/pgadmin-service.yaml
k apply -f ../raw/config-maps/backend-config-map.yaml
k apply -f ../raw/secrets/backend-secret-resolved.yaml
k apply -f ../raw/deployments/backend-deployment.yaml
k apply -f ../raw/services/backend-service.yaml
k apply -f ../raw/hpas/backend-hpa.yaml
k apply -f ../raw/network-policies/backend-db-network-policy.yaml
k apply -f ../raw/deployments/frontend-deployment.yaml
k apply -f ../raw/services/frontend-service.yaml
k apply -f ../raw/hpas/frontend-hpa.yaml
k apply -f ../raw/network-policies/frontend-backend-network-policy.yaml
k apply -f ../raw/ingresses/ingress.yaml
k config set-context --current --namespace=plug-namespace
# minikube tunnel # command asks for password for permissions
