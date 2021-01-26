# Config Connector samples

This repo contains a collection of infrastructure examples using [Kubernetes Config Connector](https://github.com/GoogleCloudPlatform/k8s-config-connector). Follow Config Connector Setup steps and then try any of the following examples:

* [WordPress on K8s + GCP CloudSQL + Workload Identity Setup](src/wp-wi/README.md)
* [WordPress on K8s + GCP Cloud SQL + WI + Gatekeeper + ACM](src/wp-acm/README.md)
* [Multi-cluster ingress](src/mci/README.md)
* [Gatekeeper integration](src/gatekeeper/README.md)
* [Multiple Team Namespace-Project Configuration](src/multiteam/README.md)
* [GCR image pull permissions from exernal K8s cluster with Config Connector](src/gcr-image/README.md)


## Config Connector Setup

1. Authenticate to GCP

    ```bash
    gcloud auth application-default login
    ```

1. Create project and cluster with Config Connector enabled:

    ```bash
    cd ./tf-provision
    terraform apply -var="project=PROJECT_ID"       \
                    -var="folder_id=FOLDER_ID"      \
                    -var="billing_account=BILLING_ACCOUNT"
    cd ..
    ```

    Note `project_id` output variable and use it in the next steps:

    ```bash
    PROJECT_ID=[project_id]

1. Set the context

    ```bash
    gcloud config set project $PROJECT_ID
    gcloud container clusters get-credentials cluster-1 --zone=us-central1-b
    ```

1. Install Config Connector resource and annotate the namespace that you will use for Config Connector resources:

    ```bash
    # we need to ensure that only instance of config-connector resource exists per cluster
    kubectl delete configconnector.core.cnrm.cloud.google.com --all
    
    # customize and install with helm:
    helm install ./config-connector-resource/. --set projectID=$PROJECT_ID --generate-name
    kubectl annotate namespace default cnrm.cloud.google.com/project-id=$PROJECT_ID
    ```

1. Verify that Config Connector is functional:

    ```bash
    kubectl wait -n cnrm-system --for=condition=Ready pod --all
    ```
