#!/bin/bash -i
source ~/.bashrc
if ! helm repo list | grep -q "the-plug-repo";
then
  helm repo add the-plug-repo https://wallys02.github.io/The-Plug-Charts/docs
  helm repo update
fi
if [ -e "values.yaml" ];
then
  export $(cat .env | xargs)
  envsubst < values-unresolved.yaml > values.yaml
fi
k apply -f plug-namespace.yaml
helm install the-plug-release the-plug-repo/the-plug -f values.yaml --namespace plug-namespace