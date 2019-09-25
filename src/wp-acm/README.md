# WordPress on K8s + GCP Cloud SQL + WI + Gatekeeper + ACM

This sample shows how Anthos Config Management can be used together with Config Connector to manage GCP infrastructure through Git worklflow.

1. Fork [this repo](https://github.com/AlexBulankou/gcp-kcc-samples)
1. Clone your fork
    ```bash
    git clone https://github.com/[my-git-user-name]/gcp-kcc-samples.git repo-name//
    ```
 
   ... and continue working with your fork.
1. [Provision project, cluster and Config Connector](../../provision.md)
1. Create two additional projects that will be holding the resources for Production and Dev environments

    ```bash
    export PROJECT_ID=[PROJECT_ID]
    export SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
    export BILLING_ACCOUNT=[BILLING_ACCOUNT]
    gcloud projects create ${PROJECT_ID}-dev --name=${PROJECT_ID}-dev
    gcloud alpha billing projects link ${PROJECT_ID}-dev --billing-account $BILLING_ACCOUNT
    gcloud projects add-iam-policy-binding ${PROJECT_ID}-dev --member "serviceAccount:${SA_EMAIL}" --role roles/owner
    gcloud projects create ${PROJECT_ID}-prod --name=${PROJECT_ID}-prod
    gcloud alpha billing projects link ${PROJECT_ID}-prod --billing-account $BILLING_ACCOUNT
    gcloud projects add-iam-policy-binding ${PROJECT_ID}-prod --member "serviceAccount:${SA_EMAIL}" --role roles/owner
    ```

1. Install ACM operator

    ```bash
    # download
    gsutil cp gs://config-management-release/released/latest/config-management-operator.yaml config-management-operator.yaml
    # apply CRD
    kubectl apply -f config-management-operator.yaml
    ```
1. Install Gatekeeper library and sample constraint template
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/templates/k8scontainterlimits_template.yaml
    ```

1. Your local fork should contain changes where PROJECT_ID template was applied. Check in these changes into Git.
1. Apply ACM config on the cluster. 

    ```bash
    kubectl apply -f ./config-management.yaml
    ```
    This should create all the objects.
1. Run `kubectl describe configmanagement` and verify that the status is `Healthy`.
1. 
1. Enable one temporary that cannot be executed declaratively. It will soon be replaced by KCC config object.
    ```bash
    PROJECT_ID=[PROJECT_ID]
    gcloud config set project ${PROJECT_ID}-dev
    SQL_SA_EMAIL=sql-wp-sa@${PROJECT_ID}-dev.iam.gserviceaccount.com
    gcloud projects add-iam-policy-binding ${PROJECT_ID}-dev --member "serviceAccount:${SQL_SA_EMAIL}" --role roles/cloudsql.client
    gcloud services enable sqladmin.googleapis.com --project ${PROJECT_ID}-dev
    gcloud config set project ${PROJECT_ID}-prod
    SQL_SA_EMAIL=sql-wp-sa@${PROJECT_ID}-prod.iam.gserviceaccount.com
    gcloud projects add-iam-policy-binding ${PROJECT_ID}-prod --member "serviceAccount:${SQL_SA_EMAIL}" --role roles/cloudsql.client
    gcloud services enable sqladmin.googleapis.com --project ${PROJECT_ID}-prod
    gcloud config set project $PROJECT_ID
    ```
