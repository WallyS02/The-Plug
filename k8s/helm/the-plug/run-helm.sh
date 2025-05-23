#!/bin/bash -i
source ~/.bashrc

if ! helm repo list | grep -q "the-plug-repo";
then
  helm repo add the-plug-repo https://wallys02.github.io/The-Plug-Charts
fi
helm repo update

if [ -e "values.yaml" ];
then
  rm values.yaml
fi

if [ -e ".env" ];
then
  set -o allexport
  source .env
  set +o allexport
fi
envsubst < values-unresolved.yaml > values.yaml

kubectl apply -f plug-namespace.yaml

helm upgrade --install the-plug-release the-plug-repo/the-plug -f values.yaml --namespace plug-namespace