#!/bin/bash

##################################################
#
# Script that removes the whole security showcase.
#
##################################################

set -e

export KUBECONFIG=/home/quarz/.kube/config

. ${0%/*}/config.sh

SEC_NS=`kubens | grep $NAMESPACE || : `
if [[ -z $SEC_NS ]] 
then
	exit 0
fi

kubectl config set-context --current --namespace=$NAMESPACE

##################################################
# Remove Helm Charts, showcase and namespace
##################################################

# Delete helm charts
#kubectl delete -f k8s/cloud-native-javaee/kubernetes/
kubectl delete -f k8s/cloud-native-javaee/kubernetes/billing-db-deployment.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/billing-db-service.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/billing-service-deployment.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/billing-service-service.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/billing-service-configmap.yaml

kubectl delete -f k8s/cloud-native-javaee/kubernetes/dashboard-service-deployment.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/dashboard-service-ingress.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/dashboard-service-service.yaml

kubectl delete -f k8s/cloud-native-javaee/kubernetes/datagrid-hazelcast-service.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/datagrid-service-configmap.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/datagrid-service-deployment.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/datagrid-service-service.yaml

kubectl delete -f k8s/cloud-native-javaee/kubernetes/message-queue-deployment.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/message-queue-service.yaml

kubectl delete -f k8s/cloud-native-javaee/kubernetes/payment-db-deployment.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/payment-db-service.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/payment-service-deployment.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/payment-service-service.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/payment-service-configmap.yaml

kubectl delete -f k8s/cloud-native-javaee/kubernetes/process-db-deployment.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/process-db-service.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/process-service-deployment.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/process-service-service.yaml
kubectl delete -f k8s/cloud-native-javaee/kubernetes/process-service-configmap.yaml


HELM_KEYCLOAK=`helm list | grep $KEYCLOAK || : `
if [[ -n $HELM_KEYCLOAK ]]
then
	helm uninstall $KEYCLOAK
	kubectl delete secret realm-secret
fi

REALM_CONFIG=`kubectl get secrets | grep realm-secret || : `
if [[ -n $REALM_CONFIG ]]
then
	kubectl create secret generic realm-secret --from-file=k8s/keycloak-helm/realm-export.json
fi

# HELM_TYK=`helm list | grep $TYK || : `
# if [[ -n $HELM_TYK ]]
# then
# 	helm uninstall redis
# 	helm uninstall $TYK
# fi

# Remove namespace security
SEC_NS=`kubens | grep $NAMESPACE || : `
if [[ -n $SEC_NS ]] 
then
	kubectl delete ns $NAMESPACE
fi


##################################################
# Clean /etc/hosts
##################################################

clean_hosts_file() {
	for host in "$@"
	do
		sed -i "/127.0.0.1 $host.local/d" /etc/hosts
	done
}

clean_hosts_file $KEYCLOAK $DASHBOARD
