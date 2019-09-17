# WordPress on K8s + GCP CloudSQL + Workload Identity Setup

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

## Enable GateKeeper:

As an additional extension, this example demonstrates the use of gatekeeper. First it applies the release version of gatekeeper, then applies constraint template.

```bash
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/demo/agilebank/templates/k8scontainterlimits_template.yaml
```

## Clean up:
``` bash
kubectl delete -f src/wp-wi/resources/
kubectl delete pvc wordpress-volume-2-wordpress-0
bash src/wp-wi/undeploy.sh
```
