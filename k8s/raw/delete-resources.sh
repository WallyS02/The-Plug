#!/bin/bash -i
source ~/.bashrc
k config set-context --current --namespace=plug-namespace
k delete ing plug-ingress
k delete networkpolicy --all
k delete hpa --all
k delete svc --all
k delete deploy --all
k delete statefulset --all
k delete secrets --all
k delete configmap backend-config-map
k delete pvc --all
k delete storageclasses db-storage-class
k delete namespace plug-namespace
k config set-context --current --namespace=default