#!/bin/bash

##################################################
#
# The script installs all components of the showcase in the Kubernetes cluster.
#
##################################################

set -e

export KUBECONFIG=/home/quarz/.kube/config

cd "${0%/*}/.."

. ${0%/*}/config.sh

# namespace for showcase
SEC_NS=`kubens | grep $NAMESPACE || : `
if [[ -z $SEC_NS ]] 
then
	kubectl create ns $NAMESPACE
fi

kubectl config set-context --current --namespace=$NAMESPACE


####################################################
# Install Keycloak
####################################################

helm repo add codecentric https://codecentric.github.io/helm-charts --force-update
helm repo update

# Setup secret from realm config file to keycloak
REALM_CONFIG=`kubectl get secrets | grep realm-secret || : `
if [[ -z $REALM_CONFIG ]]
then
	kubectl create secret generic realm-secret --from-file=k8s/keycloak-helm/realm-export.json
fi

HELM_KEYCLOAK=`helm list | grep $KEYCLOAK || : `
if [[ -z $HELM_KEYCLOAK ]] 
then
	helm install $KEYCLOAK codecentric/$KEYCLOAK --values k8s/keycloak-helm/values.yaml --wait
fi


####################################################
# Install tyk
####################################################

# helm repo add bitnami https://charts.bitnami.com/bitnami --force-update
# helm repo update

# HELM_TYK=`helm list | grep $TYK || : `
# if [[ -z $HELM_TYK ]] 
# then
# 	helm install redis bitnami/redis --set "global.redis.password=tyk" --wait
# 	helm install $TYK -f k8s/tyk-helm-chart/values_community_edition.yaml \
# 	 k8s/tyk-helm-chart/tyk-headless --wait
# fi


####################################################
# Install showcase
####################################################

sed -i "s/traefik/nginx/g" k8s/cloud-native-javaee/kubernetes/dashboard-service-ingress.yaml

kubectl apply -f k8s/cloud-native-javaee/kubernetes/billing-db-deployment.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/billing-db-service.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/billing-service-deployment.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/billing-service-service.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/billing-service-configmap.yaml

kubectl apply -f k8s/cloud-native-javaee/kubernetes/dashboard-service-deployment.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/dashboard-service-ingress.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/dashboard-service-service.yaml

kubectl apply -f k8s/cloud-native-javaee/kubernetes/datagrid-hazelcast-service.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/datagrid-service-configmap.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/datagrid-service-deployment.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/datagrid-service-service.yaml

kubectl apply -f k8s/cloud-native-javaee/kubernetes/message-queue-deployment.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/message-queue-service.yaml

kubectl apply -f k8s/cloud-native-javaee/kubernetes/payment-db-deployment.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/payment-db-service.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/payment-service-deployment.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/payment-service-service.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/payment-service-configmap.yaml

kubectl apply -f k8s/cloud-native-javaee/kubernetes/process-db-deployment.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/process-db-service.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/process-service-deployment.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/process-service-service.yaml
kubectl apply -f k8s/cloud-native-javaee/kubernetes/process-service-configmap.yaml


####################################################
# Modify /etc/hosts of master node
####################################################

modify_hosts_file() {
	# loop for all parameters
	for host in "$@"
	do
		grep -q -F "127.0.0.1 $host.local" /etc/hosts || \
		echo "127.0.0.1 $host.local" >> /etc/hosts
	done
}

modify_hosts_file $KEYCLOAK $DASHBOARD
