# Multi-Cluster Ingress

1. [Provision project, cluster and Config Connector](../../provision.md)
1. Deploy clusters and node pools for them:

    ```bash
    kubectl apply -f resources/clusters/gcp-clusters.yaml
    ```

1. Switch the context to North American cluster and create a pod and a service:

```bash
gcloud container clusters get-credentials cluster-na --zone=us-central1-a
kubectl apply -f resources/na/
```

1. Switch the context to Europe cluster and create a pod and a service:

```bash
gcloud container clusters get-credentials cluster-eu --zone=europe-west2-a
kubectl apply -f resources/eu/
```

1. Get network endpoint groups:
    ```bash
    gcloud compute network-endpoint-groups list --format="value(uri())"
    ```

    Update values in resources/lb/gcp-backend-service.yaml
1. Switch the context back the default cluster with Config Connector installed and create the load balancing resources

    ```bash
    gcloud container clusters get-credentials cluster-1 --zone=us-central1-b
    kubectl apply -f resources/lb/
    ```

1. Use `gcloud compute forwarding-rules list` to obtain forwarding rule address 
    ```bash
    $ gcloud compute forwarding-rules list
    NAME              REGION  IP_ADDRESS     IP_PROTOCOL  TARGET
    node-app-fw-rule          <your address>  TCP          node-app-target-proxy
    ```
    and try curl'ing it:
    
    ```bash
    curl <your address>
    ```
    Your should see "Hello from North America" or "Hello from Europe" dependending on what region is closer to your location.

1. Try changing one of the deployments to specify wrong image and then killing and redeploying it. If you continue curl'ing, then you will see 502 error codes, and then the service will recover and start sending the response from the region that is not closest to you.
