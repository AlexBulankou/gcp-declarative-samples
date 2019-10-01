# WordPress on K8s + GCP Cloud SQL + WI + Gatekeeper + ACM

This sample shows how Anthos Config Management can be used together with Config Connector to manage GCP infrastructure through Git worklflow.

1. Fork [this repo](https://github.com/AlexBulankou/gcp-kcc-samples)
1. Clone your fork
    ```bash
    git clone https://github.com/[my-git-user-name]/gcp-kcc-samples.git repo-name/
    ```
 
   ... and continue working with your fork.

1. Provision the project
    ```bash
    export PROJECT_ID=[PROJECT_ID]
    export BILLING_ACCOUNT=[BILLING_ACCOUNT]
    export SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"

    gcloud projects create ${PROJECT_ID} --name=${PROJECT_ID}
    gcloud alpha billing projects link ${PROJECT_ID} --billing-account $BILLING_ACCOUNT
    gcloud config set project $PROJECT_ID

    # enable container API
    gcloud services enable container.googleapis.com --project ${PROJECT_ID}

    # create service account that will be used for Config Connector
    gcloud iam service-accounts create cnrm-system --project ${PROJECT_ID}
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SA_EMAIL}" --role roles/owner
    gcloud iam service-accounts keys create --iam-account "${SA_EMAIL}" ./key.json
    ```


1. Create two additional projects that will be holding the resources for Production and Dev environments

    ```bash
    export PROJECT_ID=[PROJECT_ID]
    export SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"
    export BILLING_ACCOUNT=[BILLING_ACCOUNT]
    
    gcloud projects create ${PROJECT_ID}-dev --name=${PROJECT_ID}-dev
    gcloud alpha billing projects link ${PROJECT_ID}-dev --billing-account $BILLING_ACCOUNT
    gcloud projects add-iam-policy-binding ${PROJECT_ID}-dev --member "serviceAccount:${SA_EMAIL}" --role roles/owner
    gcloud services enable sqladmin.googleapis.com --project ${PROJECT_ID}-dev

    gcloud projects create ${PROJECT_ID}-prod --name=${PROJECT_ID}-prod
    gcloud alpha billing projects link ${PROJECT_ID}-prod --billing-account $BILLING_ACCOUNT
    gcloud projects add-iam-policy-binding ${PROJECT_ID}-prod --member "serviceAccount:${SA_EMAIL}" --role roles/owner
    gcloud services enable sqladmin.googleapis.com --project ${PROJECT_ID}-prod
    ```
1. Create GKE cluster. We are using beta API to enable Workload Identity feature.
    ```bash
    gcloud beta container clusters create ${CLUSTER_ID} --identity-namespace=${PROJECT_ID}.svc.id.goog --zone $ZONE
    gcloud container clusters get-credentials $CLUSTER_ID --zone=$ZONE
    ```

1. Install ACM operator

    ```bash
    # download
    gsutil cp gs://config-management-release/released/1.1.0/config-management-operator.yaml config-management-operator.yaml
    # apply CRD
    kubectl apply -f config-management-operator.yaml
    ```

1. Your local fork should contain changes where PROJECT_ID template was applied. Check in these changes into Git.

1. Update ./config-management file with your custom repo name. Then apply ACM config on the cluster:

    ```bash
    kubectl apply -f ./config-management.yaml
    ```

    This should create all the objects.

1. Run `kubectl describe configmanagement` and verify that the status is `Healthy`. 

1. Wait some time for resources to sync.

1. Once `cnrm-system` namespace is created, propagate permissions from Config Connector service account to cnrm-system namespace, where we have Config Connector pod

    ```bash
    # give cnrm-system namespace permissions to manage GCP
    kubectl create secret generic gcp-key --from-file ./key.json --namespace cnrm-system
    ```
    This enables Config Connector resources to initialize.

1. Wait some time for resources to sync. Verify that service account resources are created:

    ```bash
    kubectl describe iamserviceaccount --all-namespaces
    ```

    Last update on both should say: `The resource is up to date`.

1. Enable one temporary that cannot be executed declaratively. It will soon be replaced by Config Connector declarative config
    ```bash
    PROJECT_ID=[PROJECT_ID]
    gcloud config set project ${PROJECT_ID}-dev
    SQL_SA_EMAIL_DEV=sql-wp-sa@${PROJECT_ID}-dev.iam.gserviceaccount.com
    gcloud projects add-iam-policy-binding ${PROJECT_ID}-dev --member "serviceAccount:${SQL_SA_EMAIL_DEV}" --role roles/cloudsql.client
    gcloud services enable sqladmin.googleapis.com --project ${PROJECT_ID}-dev

    gcloud config set project ${PROJECT_ID}-prod
    SQL_SA_EMAIL_PROD=sql-wp-sa@${PROJECT_ID}-prod.iam.gserviceaccount.com
    gcloud projects add-iam-policy-binding ${PROJECT_ID}-prod --member "serviceAccount:${SQL_SA_EMAIL_PROD}" --role roles/cloudsql.client
    gcloud services enable sqladmin.googleapis.com --project ${PROJECT_ID}-prod
    gcloud config set project $PROJECT_ID
    ```
