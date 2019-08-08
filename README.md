# Config Connector samples

This repo contains a collection of infrastructure examples using [Kubernetes Config Connector](https://github.com/GoogleCloudPlatform/k8s-config-connector).

## WordPress on K8s + GCP CloudSQL Setup

This example shows how you can deploy Wordpress to your Kubernetes cluster, backed by Google CloudSQL database. Once Kubernetes Config Connector is enabled, the whole installation takes a single kubectl command to run.

One limitation of Config Connector today is that sql_user resource is referencing credentials in clear text. Once secretRef's are supported, it will be possible to reference database credentials from Kubernetes secret resource.

1. Replace with your project name.

    ```bash
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/[PROJECT_ID]/your_project_id/g' {} \;
    ```

1. Initialize project and cluster:

    ```bash
    bash src/provision-project.sh
    bash src/provision-cluster.sh
    ```

1. Deploy:

    ```bash
    kubectl apply -f src/wp-simple/resources/
    ```

## WordPress on K8s + GCP CloudSQL + Workload Identity Setup

This extends the previous example by enabling Workload Identity integration. This requires 4 additional resources:
* [Google service account (GSA)](src/wp-wi/resources/sql-service-account.yaml)
* [sqlclient permission for GSA](src/wp-wi/deploy.sh). Currently this step is done via gcloud command, however soon it will be possible to configure individual binding declaratively.
* [Kubernetes service account (KSA)](src/wp-wi/resources/k8s-service-account.yaml) annotated with GSA
* [Workload identity permission for GSA](src/wp-wi/resources/wi-policy.yaml) that links GSA and KSA

In this sample there's no longer needed to mount keys in the [pod configuration](src/wp-wi/resources/stateful-set.yaml) as SQL client permissions are propagated through Kubernetes service account. (note serviceAccountName field in pod config).

1. Replace with your project name.

    ```bash
       LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/[PROJECT_ID]/your_project_id/g' {} \;
    ```

1. Initialize project and cluster:

    ```bash
    bash src/provision-project.sh
    bash src/provision-cluster.sh
    ```

1. Deploy:

    ```bash
    kubectl apply -f src/wp-wi/resources/
    ```

1. Enable SQL account binding. This step will be replaced with declarative config:

    ```bash
    bash src/wp-wi/deploy.sh
    ```
