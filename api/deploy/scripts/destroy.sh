#!/bin/bash

uninstall_helm_chart() {
    echo "Uninstalling Helm chart..."
    helm uninstall clipper --namespace clipper
}

delete_namespace() {
    echo "Deleting namespace clipper..."
    kubectl delete namespace clipper
}

destroy_service() {
    uninstall_helm_chart
    delete_namespace
}

destroy_service
