#!/bin/bash -i
source ~/.bashrc
if ! minikube status | grep -q "host: Running";
then
  chmod +x ./set-up-cluster.sh
  ./set-up-cluster.sh
fi
k apply -f ./namespaces/plug-namespace.yaml
k apply -f ./storage-classes/db-storage-class.yaml
k apply -f ./pvces/db-pvc.yaml
k apply -f ./secrets/db-secret-resolved.yaml
k apply -f ./stateful-sets/db-stateful-set.yaml
k apply -f ./services/db-service.yaml
k apply -f ./secrets/pgadmin-secret-resolved.yaml
k apply -f ./hpas/db-hpa.yaml
k apply -f ./deployments/pgadmin-deployment.yaml
k apply -f ./services/pgadmin-service.yaml
k apply -f ./config-maps/backend-config-map.yaml
k apply -f ./secrets/backend-secret-resolved.yaml
k apply -f ./deploymentsbackend-deployment.yaml
k apply -f ./servicesbackend-service.yaml
k apply -f ./hpasbackend-hpa.yaml
k apply -f ./network-policiesbackend-db-network-policy.yaml
k apply -f ./deploymentsfrontend-deployment.yaml
k apply -f ./servicesfrontend-service.yaml
k apply -f ./hpasfrontend-hpa.yaml
k apply -f ./network-policiesfrontend-backend-network-policy.yaml
k apply -f ./ingressesingress.yaml
k config set-context --current --namespace=plug-namespace
# minikube tunnel # command asks for password for permissions
