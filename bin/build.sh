#!/bin/bash

##################################################
#
# The script installs all components of the showcase in the Kubernetes cluster.
#
##################################################

set -e

cd "${0%/*}/.."

cd "k8s/cloud-native-javaee/microservices/billing-service"
./gradlew clean build

cd "../dashboard-service"
./gradlew clean build

cd "../datagrid-service"
./gradlew clean build

cd "../payment-service"
./gradlew clean build

cd "../process-service"
./gradlew clean build

cd "../../../dashboard-dockerfile"
docker login
if [[ -n $(Docker images | grep "xquarz/dashboard-service") ]]
then
        docker rmi xquarz/dashboard-service
fi

docker build -t xquarz/dashboard-service .
docker push xquarz/dashboard-service

cd "../process-dockerfile"
if [[ -n $(Docker images | grep "xquarz/process-service") ]]
then
        docker rmi xquarz/process-service
fi

docker build -t xquarz/process-service .
docker push xquarz/process-service