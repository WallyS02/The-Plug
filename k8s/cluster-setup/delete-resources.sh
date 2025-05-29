#!/bin/bash -i
source ~/.bashrc
kubectl config set-context --current --namespace=plug-namespace
kubectl delete ing plug-ingress
kubectl delete networkpolicy --all
kubectl delete hpa --all
kubectl delete svc --all
kubectl delete deploy --all
kubectl delete statefulset --all
kubectl delete secrets --all
kubectl delete configmap backend-config-map
kubectl delete pvc --all
kubectl delete storageclasses db-storage-class
kubectl delete namespace plug-namespace
kubectl config set-context --current --namespace=default