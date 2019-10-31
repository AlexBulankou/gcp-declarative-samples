# Multi-Cluster Ingress with Auto-NEG

1. [Provision project, cluster and Config Connector](../../provision.md)
1. Create clusters:

    ```bash
    kubectl apply -f resources/clusters/gcp-clusters.yaml
    ```

1. Switch the context to North American cluster and create a pod and a service:

    ```bash
    gcloud container clusters get-credentials cluster-na --zone=us-central1-a
    kubectl apply -f na/
    ```

1. Switch the context to Europe cluster and create a pod and a service:

    ```bash
    gcloud container clusters get-credentials cluster-eu --zone=europe-west2-a
    kubectl apply -f eu/
    ```

1. Back to main cluster

    ```bash
    gcloud container clusters get-credentials cluster-1 --zone=us-central1-b
    kubectl apply -f resources/lb/
    ```
