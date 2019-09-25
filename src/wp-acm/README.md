# WordPress on K8s + GCP Cloud SQL + WI + Gatekeeper + ACM

This sample shows how Anthos Config Management can be used together with Config Connector to manage GCP infrastructure through Git worklflow.

1. [Provision project, cluster and Config Connector](../../provision.md)
1. Create two additional projects that will be holding the resources for Production and Dev environments

    ```bash
    export PROJECT_ID=[PROJECT_ID]
    export SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
    export BILLING_ACCOUNT=[BILLING_ACCOUNT]
    gcloud projects create ${PROJECT_ID}-dev --name=${PROJECT_ID}-dev
    gcloud alpha billing projects link ${PROJECT_ID}-dev --billing-account $BILLING_ACCOUNT
    gcloud projects add-iam-policy-binding ${PROJECT_ID}-prod --member "serviceAccount:${SA_EMAIL}" --role roles/owner
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
1. Fork [this repo](https://github.com/AlexBulankou/gcp-kcc-samples)
1. Clone your fork git clone git@github.com:[my-git-username]/gcp-kcc-samples.git
1. Apply ACM config on the cluster
1. 
