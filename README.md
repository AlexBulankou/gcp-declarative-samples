# Config Connector samples

This repo contains a collection of infrastructure examples using [Kubernetes Config Connector](https://github.com/GoogleCloudPlatform/k8s-config-connector).

## WordPress on K8s + GCP CloudSQL Setup

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
### Clean up:
``` bash
kubectl delete -f src/wp-simple/resources/
kubectl delete pvc wordpress-volume-wordpress-0
```

## WordPress on K8s + GCP CloudSQL + Workload Identity Setup

This extends the previous example by enabling Workload Identity integration. This requires 4 additional resources:
* [Google service account (GSA)](src/wp-wi/resources/sql-service-account.yaml)
* [Sqlclient permission for GSA](src/wp-wi/deploy.sh). Currently this step is done via gcloud command, however soon it will be possible to configure individual binding declaratively.
* [Kubernetes service account (KSA)](src/wp-wi/resources/k8s-service-account.yaml) annotated with GSA
* [Workload identity permission for GSA](src/wp-wi/resources/wi-policy.yaml) that links GSA and KSA

In this sample there's no longer needed to mount keys in the [pod configuration](src/wp-wi/resources/stateful-set.yaml) as SQL client permissions are propagated through Kubernetes service account. Note: don't forget serviceAccountName field in pod config.

1. Replace with your project name.

    ```bash
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/\[PROJECT_ID\]/your_project_id/g' {} \;
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/\[BILLING_ACCOUNT\]/your_billing_account/g' {} \;
    ```

1. Initialize project and cluster:

    ```bash
    bash src/provision.sh
    ```

1. Deploy:

    ```bash
    kubectl apply -f src/wp-wi/resources/
    ```

1. Enable SQL account binding after account is created. This step will be replaced with declarative config:

    ```bash
    kubectl wait --for=condition=Ready iamserviceaccount/sql-wp-sa --timeout=30m
    bash src/wp-wi/deploy.sh
    ```

1. Wait for sql instance to be ready
    ```bash
    # Note that you can wait on the proxy resources too
    kubectl wait --for=condition=Ready sqlinstance/wp-db --timeout=30m
    kubectl wait --for=condition=Ready sqluser/wordpress --timeout=30m

    # But ultimately you need to wait on the pod to be created
    kubectl wait --for=condition=Ready pods/wordpress-0 --timeout=30m
    ```

### Enable GateKeeper:

As an additional extension, this example demonstrates the use of gatekeeper. First it applies the release version of gatekeeper, then applies constraint template.

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/templates/k8scontainterlimits_template.yaml
```

### Clean up:
``` bash
kubectl delete -f src/wp-wi/resources/
kubectl delete pvc wordpress-volume-2-wordpress-0
bash src/wp-wi/undeploy.sh
```

## Multi-Cluster Ingress

1. Replace with your project name and billing account:

    ```bash
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/\[PROJECT_ID\]/your_project_id/g' {} \;
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/\[BILLING_ACCOUNT\]/your_billing_account/g' {} \;
    ```
1. Initialize project and cluster:

    ```bash
    bash src/provision.sh
    ```
1. Deploy clusters and node pools for them:

    ```bash
    kubectl apply -f src/mci/resources/gcp-clusters.yaml
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
kubectl apply -f src/mci/na/
```

1. Switch the context to Europe cluster and create a pod and a service:

```bash
gcloud container clusters get-credentials cluster-eu --zone=europe-west2-a
kubectl apply -f src/mci/eu/
```
1. Set named port on the instance groups:

```bash
gcloud compute instance-groups managed set-named-ports  ig-eu  --named-ports port31028:31028 --zone=europe-west2-a
gcloud compute instance-groups managed set-named-ports  ig-na  --named-ports port31028:31028 --zone=us-central1-a
```

1. Switch the context back the default cluster with Config Connector installed and create backend service, health check.

    ```bash
    gcloud container clusters get-credentials cluster-1 --zone=us-central1-b
    kubectl apply -f src/mci/resources/gcp-backend-service.yaml
    ```

1. Acquire default network and create firewall rule:

```bash
    kubectl apply -f src/mci/resources/gcp-default-network.yaml
    kubectl apply -f src/mci/resources/gcp-compute-firewall.yaml
```



BTW, to create firewall rule using gcloud:
    ```bash
    gcloud compute firewall-rules create rule-31028  --allow=tcp:31028
    ```

1. Observe you can see newly created backend service with 2 groups and instances healthy.
1. Create target http proxy and url map:

    ```bash
    kubectl apply -f src/mci/resources/gcp-target-http-proxy.yaml
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

