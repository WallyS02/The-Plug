#!/bin/bash -i
source ~/.bashrc
k config set-context --current --namespace=plug-namespace
k delete ing plug-ingress
k delete networkpolicy
k delete hpa
k delete svc
k delete deploy
k delete statefulset
k delete secrets
k delete configmap backend-config-map
k delete pvc
k delete storageclasses db-storage-class
k delete namespace plug-namespace
k config set-context --current --namespace=default