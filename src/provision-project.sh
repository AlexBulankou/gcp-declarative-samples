#!/bin/bash

PROJECT_ID=[PROJECT_ID]
ZONE=us-central1-a

ls $PROJECT_ID

SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"

# once per project
gcloud iam service-accounts create cnrm-system --project ${PROJECT_ID}
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SA_EMAIL}" --role roles/owner
gcloud iam service-accounts keys create --iam-account "${SA_EMAIL}" ./key.json

gcloud services enable pubsub.googleapis.com --project ${PROJECT_ID}
gcloud services enable spanner.googleapis.com --project ${PROJECT_ID}
gcloud services enable sqladmin.googleapis.com --project ${PROJECT_ID}
gcloud services enable redis.googleapis.com --project ${PROJECT_ID}
gcloud services enable cloudresourcemanager.googleapis.com --project ${PROJECT_ID}
gcloud services enable container.googleapis.com --project ${PROJECT_ID}
