#!/bin/bash

##################################################
#
# The script forwards Keycloak endpoint.
#
##################################################

set -e

export POD_NAME=$(kubectl get pods --namespace security -l "app.kubernetes.io/name=keycloak,app.kubernetes.io/instance=keycloak" -o name)
echo "Visit http://127.0.0.1:8080 to use your application"
kubectl --namespace security port-forward "$POD_NAME" 8080