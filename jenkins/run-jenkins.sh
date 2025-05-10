docker network create jenkins

docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2

docker run \
  --name the-plug-jenkins \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --env JENKINS_OPTS="--httpPort=80" \
  --publish 8080:80 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  --volume /home/wallys/.minikube:/var/jenkins_home/.minikube \
  --volume /home/wallys/.kube:/var/jenkins_home/.kube \
  wallys02/the-plug-jenkins:latest

# Save original config
cp -r /home/wallys/.minikube /home/wallys/minikube-host-config
cp -r /home/wallys/.kube /home/wallys/kube-host-config

# Change config for Jenkins
MINIKUBE_API_PORT=$(docker inspect -f '{{(index (index .NetworkSettings.Ports "8443/tcp") 0).HostPort}}' minikube)
docker exec the-plug-jenkins bash -c "
kubectl config delete-cluster minikube;
kubectl config delete-context minikube;
kubectl config set-cluster minikube \
    --server=https://host.docker.internal:$MINIKUBE_API_PORT \
    --insecure-skip-tls-verify=true;
kubectl config set-credentials minikube-user \
    --client-certificate=/var/jenkins_home/.minikube/profiles/minikube/client.crt \
    --client-key=/var/jenkins_home/.minikube/profiles/minikube/client.key;
kubectl config set-context minikube \
    --cluster=minikube \
    --user=minikube-user;
kubectl config use-context minikube;"

# Restore original config
cp -Tr /home/wallys/minikube-host-config /home/wallys/.minikube
cp -Tr /home/wallys/kube-host-config /home/wallys/.kube