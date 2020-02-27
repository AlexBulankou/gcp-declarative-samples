#!/bin/bash
set -e

export PROJECT_ID=[PROJECT_ID]
export BILLING_ACCOUNT=[BILLING_ACCOUNT]
export CLUSTER_ID=cluster-1
export ZONE=us-central1-b
export SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
export WP_SA_EMAIL=sql-wp-sa@${PROJECT_ID}.iam.gserviceaccount.com


gcloud projects create $PROJECT_ID --name="$PROJECT_ID" --folder=[FOLDER_ID]
gcloud alpha billing projects link $PROJECT_ID --billing-account $BILLING_ACCOUNT
gcloud config set project $PROJECT_ID


# provision project
gcloud iam service-accounts create cnrm-system --project ${PROJECT_ID}
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SA_EMAIL}" --role roles/owner
gcloud iam service-accounts keys create --iam-account "${SA_EMAIL}" ./key.json

gcloud services enable pubsub.googleapis.com --project ${PROJECT_ID}
gcloud services enable spanner.googleapis.com --project ${PROJECT_ID}
gcloud services enable sqladmin.googleapis.com --project ${PROJECT_ID}
gcloud services enable redis.googleapis.com --project ${PROJECT_ID}
gcloud services enable cloudresourcemanager.googleapis.com --project ${PROJECT_ID}
gcloud services enable container.googleapis.com --project ${PROJECT_ID}
gcloud services enable dns.googleapis.com --project ${PROJECT_ID}


# for each cluster
# Note: this creates a cluster with workload identity enabled, using Beta API
gcloud beta container clusters create ${CLUSTER_ID} --identity-namespace=${PROJECT_ID}.svc.id.goog --zone $ZONE
gcloud container clusters get-credentials $CLUSTER_ID --zone=$ZONE

# install KCC
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)
gsutil cp gs://cnrm/latest/release-bundle.tar.gz release-bundle.tar.gz
rm -rf release-bundle
tar zxvf release-bundle.tar.gz
kubectl apply -f install-bundle-gcp-identity/

# give cnrm-system namespace permissions to manage GCP
kubectl create secret generic gcp-key --from-file ./key.json --namespace cnrm-system

# annotate the namespace
kubectl annotate namespace default "cnrm.cloud.google.com/project-id=${PROJECT_ID}" --overwrite
