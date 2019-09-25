# Multi-Cluster Ingress

1. [Provision project, cluster and Config Connector](../../provision.md)
1. Deploy clusters and node pools for them:

    ```bash
    kubectl apply -f resources/gcp-clusters.yaml
    ```

This deployed 2 clusters. Now let's deploy node pools for them
    ```bash
    gcloud container node-pools create node-pool-na --cluster=cluster-na --zone=us-central1-a
    gcloud container node-pools create node-pool-eu --cluster=cluster-eu \
        --zone=europe-west2-a
    ```

Let's now replace the instance groups in these node pools. This is a temporary hack needed until instance groups are supported by Config Connector.

```bash
# run these steps for EU cluster
EU_GROUP_NAME=$(gcloud container node-pools describe node-pool-eu --cluster=cluster-eu --zone=europe-west2-a --format='value[](instanceGroupUrls)')
EU_TEMPLATE_NAME=${EU_GROUP_NAME%-grp}
EU_TEMPLATE_NAME=$(basename $EU_TEMPLATE_NAME)
gcloud compute instance-groups managed create ig-eu --template=$EU_TEMPLATE_NAME --size=3 --zone=europe-west2-a
gcloud compute instance-groups managed delete $EU_GROUP_NAME --zone=europe-west2-a

# repeat the steps for NA cluster
NA_GROUP_NAME=$(gcloud container node-pools describe node-pool-na --cluster=cluster-na --zone=us-central1-a --format='value[](instanceGroupUrls)')
NA_TEMPLATE_NAME=${NA_GROUP_NAME%-grp}
NA_TEMPLATE_NAME=$(basename $NA_TEMPLATE_NAME)
gcloud compute instance-groups managed create ig-na --template=$NA_TEMPLATE_NAME --size=3 --zone=us-central1-a
gcloud compute instance-groups managed delete $NA_GROUP_NAME --zone=us-central1-a

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
1. Set named port on the instance groups:

```bash
gcloud compute instance-groups managed set-named-ports  ig-eu  --named-ports port31028:31028 --zone=europe-west2-a
gcloud compute instance-groups managed set-named-ports  ig-na  --named-ports port31028:31028 --zone=us-central1-a
```

1. Switch the context back the default cluster with Config Connector installed and create backend service, health check.

    ```bash
    gcloud container clusters get-credentials cluster-1 --zone=us-central1-b
    kubectl apply -f resources/gcp-backend-service.yaml
    ```

1. Acquire default network and create firewall rule:

```bash
    kubectl apply -f resources/gcp-default-network.yaml
    kubectl apply -f resources/gcp-compute-firewall.yaml
```



BTW, to create firewall rule using gcloud:
    ```bash
    gcloud compute firewall-rules create rule-31028  --allow=tcp:31028
    ```

1. Observe you can see newly created backend service with 2 groups and instances healthy.
1. Create target http proxy and url map:

    ```bash
    kubectl apply -f resources/gcp-target-http-proxy.yaml
    ```

    With gcloud:

    ```bash
    gcloud compute url-maps create node-app-url-map --default-service=node-app-backend-service
    gcloud compute target-http-proxies create node-app-target-proxy  --url-map=node-app-url-map
    ```
1. Finally create forwarding rule:
    ```bash
    gcloud compute forwarding-rules create node-app-fw-rule --target-http-proxy=node-app-target-proxy --global --ports=80
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
