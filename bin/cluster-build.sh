#!/bin/bash

####################################################
#
# Setup gke cluster
#
####################################################

set -e

CLUSTER_NAME="ma"

GKE=`gcloud container clusters list | grep $CLUSTER_NAME || : `
if [[ -z $GKE ]]
then
	gcloud container clusters create $CLUSTER_NAME --cluster-version="1.17.16-gke.1300" --zone europe-west4-a --node-locations europe-west4-a --preemptible --num-nodes=6 --enable-autoscaling --max-nodes=6 --min-nodes=0 --machine-type=e2-medium
fi

gcloud container clusters get-credentials $CLUSTER_NAME
