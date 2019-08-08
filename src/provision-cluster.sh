#!/bin/bash

PROJECT_ID=[PROJECT_ID]
CLUSTER_ID=cluster-1
ZONE=us-central1-a
KCC_BUNDLE_DIR=kcc-install-bundle/0.0.9/install-bundle

gcloud config set project $PROJECT_ID
# Note: this creates a cluster with workload identity enabled, using Beta API
gcloud beta container clusters create ${CLUSTER_ID} --identity-namespace=${PROJECT_ID}.svc.id.goog --zone $ZONE
gcloud container clusters get-credentials $CLUSTER_ID --zone=$ZONE

SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
SA_EMAIL_DEMO="cnrm-application-demo@${PROJECT_ID}.iam.gserviceaccount.com"

# for each cluster
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)
kubectl apply -R -f ${KCC_BUNDLE_DIR}
kubectl create secret generic gcp-key --from-file ./key.json --namespace cnrm-system

# for each namespace
kubectl create secret generic gcp-key --from-file=./key-editor.json
kubectl create secret generic gcp-key-owner --from-file ./key.json
kubectl annotate namespace default "cnrm.cloud.google.com/project-id=${PROJECT_ID}" --overwrite
