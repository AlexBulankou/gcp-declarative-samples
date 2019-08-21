#!/bin/bash

PROJECT_ID=[PROJECT_ID]
CLUSTER_ID=cluster-1
ZONE=us-central1-a
KCC_BUNDLE_DIR=kcc-install-bundle/0.0.10/install-bundle

gcloud config set project $PROJECT_ID
# Note: this creates a cluster with workload identity enabled, using Beta API
gcloud beta container clusters create ${CLUSTER_ID} --identity-namespace=${PROJECT_ID}.svc.id.goog --zone $ZONE
gcloud container clusters get-credentials $CLUSTER_ID --zone=$ZONE


# install KCC
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)
kubectl apply -f ${KCC_BUNDLE_DIR}

# give cnrm-system namespace permissions to manage GCP
kubectl create secret generic gcp-key --from-file ./key.json --namespace cnrm-system

# for each namespace generic gcp-key-owner --from-file ./key.json


kubectl annotate namespace default "cnrm.cloud.google.com/project-id=${PROJECT_ID}" --overwrite
