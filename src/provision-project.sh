#!/bin/bash

# LC_CTYPE=C && find ./ -type f -exec sed -i '' 's/old_project_name/new_project_name/g' {} \;

PROJECT_ID=[PROJECT_ID]
ZONE=us-central1-a

gcloud config set project $PROJECT_ID

SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
SA_EMAIL_DEMO="cnrm-application-demo@${PROJECT_ID}.iam.gserviceaccount.com"

# once per project
gcloud iam service-accounts create cnrm-system --project ${PROJECT_ID}
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SA_EMAIL}" --role roles/owner
gcloud iam service-accounts keys create --iam-account "${SA_EMAIL}" ./key.json

gcloud iam service-accounts create cnrm-application-demo --project ${PROJECT_ID}
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SA_EMAIL_DEMO}" --role roles/editor
gcloud iam service-accounts keys create --iam-account ${SA_EMAIL_DEMO} ./key-editor.json

gcloud services enable pubsub.googleapis.com --project ${PROJECT_ID}
gcloud services enable spanner.googleapis.com --project ${PROJECT_ID}
gcloud services enable sqladmin.googleapis.com --project ${PROJECT_ID}
gcloud services enable redis.googleapis.com --project ${PROJECT_ID}
gcloud services enable cloudresourcemanager.googleapis.com --project ${PROJECT_ID}
gcloud services enable container.googleapis.com --project ${PROJECT_ID}
