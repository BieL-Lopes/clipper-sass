#!/bin/bash

set -e
set -o pipefail

start_minikube() {
 echo "Verifying if Minikube is running..."
 if ! minikube status &> /dev/null; then
   echo "Starting minikube..."
   minikube start --insecure-registry localhost:5000 --ports=80:80 --ports=443:443 --cpus=max --memory=max
   minikube addons enable registry
   minikube addons enable ingress
   minikube addons enable ingress-dns
   minikube ssh sudo apt-get update && sudo apt-get -y install qemu-user-static
 else
   echo "Minikube is already running"
 fi
}

main() {
  start_minikube
}

main
