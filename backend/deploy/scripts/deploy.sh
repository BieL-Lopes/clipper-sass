#!/bin/bash

set -e
set -o pipefail

raise_error() {
  local message="$1"
  echo "Error: $message"
  exit 1
}

build_docker_image() {
    echo "Building the docker image..."
    docker_path="$1"
    if [ -z "$docker_path" ]; then
        docker_path="."
    fi

    docker build -t clipper-app:latest "$docker_path"
}

tag_docker_image() {
    echo "Tagging the image to the local registry at local minikube..."
    docker tag clipper-app:latest localhost:5000/clipper-app:latest
}

push_docker_image() {
    echo "Pushing the docker image to local registry at local minikube..."
    docker push localhost:5000/clipper-app:latest
}

create_namespace_clipper() {
    echo "Checking if the namespace already exists..."
    if ! kubectl get namespace clipper > /dev/null 2>&1; then
        echo "Creating namespace clipper..."
        kubectl create namespace clipper
    else
        echo "The clipper namespace already exists."
    fi
}

check_minikube() {
  echo "Verifying if Minikube is running..."
  if ! minikube status &> /dev/null; then
    raise_error "Minikube is not running. please run the start_minikube func located at client deploy script."
  else
    echo "All right, Minikube is already running"
  fi
}

update_or_install_helm_chart() {
    echo "Installing Helm Chart for the great Transcriber tool..."
    chart_path="$1"
    if [ -z "$chart_path" ]; then
        chart_path="./deploy/chart"
    fi

    helm upgrade --install clipper "$chart_path" --namespace clipper --values ./deploy/values/local.yaml
}

deploy() {
  check_minikube
  build_docker_image "$1"
  tag_docker_image
  push_docker_image
  create_namespace_clipper
  update_or_install_helm_chart "$2"
}

deploy "$1" "$2"
