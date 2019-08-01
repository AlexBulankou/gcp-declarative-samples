#!/bin/bash


PROJECT_ID=alexbu-kcc-wp4
SA_NAME="wordpress-db-access@${PROJECT_ID}.iam.gserviceaccount.com"


kubectl apply -f ./resources/

gcloud iam service-accounts keys create --iam-account ${SA_NAME} ./credentials.json
kubectl delete secret cloudsql-instance-credentials
kubectl -n default create secret generic cloudsql-instance-credentials \
 --from-file=credentials.json=./credentials.json

