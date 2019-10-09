# WordPress on K8s + GCP CloudSQL Setup

This example shows how you can deploy Wordpress to your Kubernetes cluster, backed by Google CloudSQL database. Once Kubernetes Config Connector is enabled, the whole installation takes a single kubectl command to run.

One limitation of Config Connector today is that sql_user resource is referencing credentials in clear text. Once secretRef's are supported for sensitive fields, it will be possible to reference database credentials from Kubernetes secrets.

1. [Provision project, cluster and Config Connector](../../provision.md)
1. Deploy:

    ```bash
    kubectl apply -f resources/
    ```
1. Run one additonal temporary step required, as this sample is using cnrm-system key. This will be soon replaced by using service account object created by Config Connector.

    ```bash
    kubectl create secret generic gcp-key --from-file ./key.json
    ```
    
## Clean up:
``` bash
kubectl delete -f resources/
kubectl delete pvc wordpress-volume-wordpress-0
```
