#!/bin/bash

##################################################
#
# Script that deletes the gke cluster
#
##################################################

set -e

GKE=`gcloud container clusters list | grep ma || : `
if [[ -n $GKE ]]
then
	gcloud container clusters delete ma --quiet
fi
