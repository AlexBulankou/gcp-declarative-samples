PROJECT_ID=[PROJECT_ID]
SA_EMAIL=sql-wp-sa@${PROJECT_ID}.iam.gserviceaccount.com
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SA_EMAIL}" --role roles/cloudsql.client
