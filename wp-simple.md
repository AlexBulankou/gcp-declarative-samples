# WordPress on K8s + GCP CloudSQL Setup

This example shows how you can deploy Wordpress to your Kubernetes cluster, backed by Google CloudSQL database. Once Kubernetes Config Connector is enabled, the whole installation takes a single kubectl command to run.

One limitation of Config Connector today is that sql_user resource is referencing credentials in clear text. Once secretRef's are supported for sensitive fields, it will be possible to reference database credentials from Kubernetes secrets.

1. Replace with your project name and billing account:

    ```bash
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/\[PROJECT_ID\]/your_project_id/g' {} \;
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/\[BILLING_ACCOUNT\]/your_billing_account/g' {} \;
    ```

1. Initialize project and cluster:

    ```bash
    bash src/provision.sh

1. Deploy:

    ```bash
    kubectl apply -f src/wp-simple/resources/
    ```

## Clean up:
``` bash
kubectl delete -f src/wp-simple/resources/
kubectl delete pvc wordpress-volume-wordpress-0
```