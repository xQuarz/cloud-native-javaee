#!/bin/bash

##################################################
#
# The script forwards Dashboard of showcase endpoint.
#
##################################################

set -e

gcloud container clusters get-credentials ma --zone europe-west4-a --project steffi-ma && kubectl port-forward --namespace security $(kubectl get pod --namespace security --selector="io.kompose.service=dashboard-service" --output jsonpath='{.items[0].metadata.name}') 8080:8080
