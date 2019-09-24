export PROJECT_ID=[PROJECT_ID]
export SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"


# configure project and permissions for team-a

# create dedicated project for team-a
gcloud projects create ${PROJECT_ID}-team-a --name=${PROJECT_ID}-team-a

# give team-a viewer permission to the main project
# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
# --member group:team-a@googlegroups.com \
# --role roles/viewer

# give team-a editor permission to the dedicated project
# gcloud projects add-iam-policy-binding ${PROJECT_ID}-team-a \
# --member group:team-a@googlegroups.com \
# --role roles/editor

# give cnrm system access to team-a dedicated project
gcloud projects add-iam-policy-binding ${PROJECT_ID}-team-a --member "serviceAccount:${SA_EMAIL}" --role roles/owner
gcloud projects add-iam-policy-binding ${PROJECT_ID}-team-a --member "serviceAccount:${SA_EMAIL}" --role roles/storage.admin

# create dedicated project for team-b
gcloud projects create ${PROJECT_ID}-team-b --name=${PROJECT_ID}-team-b

# give team-b viewer permission to the main project
# gcloud projects add-iam-policy-binding ${PROJECT_ID} \
# --member group:team-b@googlegroups.com \
# --role roles/viewer

# give team-b editor permission to the dedicated project
# gcloud projects add-iam-policy-binding ${PROJECT_ID}-team-b \
# --member group:team-b@googlegroups.com \
# --role roles/editor

# give cnrm system access to team-b dedicated project
gcloud projects add-iam-policy-binding ${PROJECT_ID}-team-b --member "serviceAccount:${SA_EMAIL}" --role roles/owner
gcloud projects add-iam-policy-binding ${PROJECT_ID}-team-b --member "serviceAccount:${SA_EMAIL}" --role roles/storage.admin
