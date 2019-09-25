# Namespace-Project Configuration for Multiple Teams

We'll provision multiple Kubernetes namespaces, namespace per team. For each namespace:
* There will be a associated GCP project for cloud infrastructure
* K8s service account (KSA) linked to Google Service Account (GSA) on GCP side using Workload Identity
* To illustrate this example, a pod communicating to Google Storage Bucket in GCP project

1. [Provision project and cluster with Config Connector enamed](/provision.md)
1. Create projects team-a and team-b dedicated for two teams. Give permissions to Config Connector to manage resources in these projects. You can aso uncomment part of the script to create groups and give them permissions to projects:

    ```bash
    bash ../provision-projects.sh
    ```

1. Create K8s namespace dedicated to team-a resources:

    ```bash
    kubectl apply -f team-a/resources-admin/k8s-namespace.yaml
    ```

1. Configure permissions for this team-a-user to edit standard resources in this namespace and also give them cnrm-manager role to edit Config Connector resoruces, such as buckets.

    ```bash
    kubectl apply -f team-a/resources-admin/k8s-namespace-permissions.yaml
    ```
1. Repeat previous two steps for team-b-user:

    ```bash
    kubectl apply -f team-b/resources-admin/k8s-namespace.yaml
    kubectl apply -f team-b/resources-admin/k8s-namespace-permissions.yaml
    ```

1. Verify that team-a-user can create pods or sqlinstances in team-a namespace, but cannot do this in team-b or default namespace:
    ```bash
    $ kubectl auth can-i create pods --namespace team-a --as=team-a-user
    yes
    $ kubectl auth can-i create sqlinstances --namespace team-a --as=team-a-user
    yes
    $ kubectl auth can-i create sqlinstances --namespace team-b --as=team-a-user
    no
    $ kubectl auth can-i create sqlinstances --as=team-a-user
    no
    ```
1. Try to modify team-a namespace to point it to a different project. You will get an error:
    ```
    error: namespaces "team-a" could not be patched: namespaces "team-a" is forbidden: User "team-a-user" cannot patch resource "namespaces" in API group "" in the namespace "team-a"
    ```
1. Create `team-a` resources, impersonating team member:
    ```bash
    kubectl apply -f team-a/resources-team --as=team-a-user
    ```
1. Verify that service account credentials are propagating automatically. Run a pod with `google/cloud-sdk` image:
    ```
    kubectl run -it \
    --generator=run-pod/v1 \
    --image google/cloud-sdk \
    --serviceaccount ksa-bucket-team-a\
    --namespace team-a \
    team-a-ksa-test --as=team-a-user
    ```
1. Once on the pod, run the following to test your permissions:
    ```bash
    gcloud auth list # google service account should be listed
    # create file
    echo some text > f1.txt
    # copy to bucket, shoudl succeed
    gsutil cp f1.txt gs://alexbu-kcc-multiteam-team-a-bucket
    # list files in bucket, should succeed
    gsutil ls gs://alexbu-kcc-multiteam-team-a-bucket
    ```

1. Replicate the same configuration for team-b:

    ```bash
    kubectl apply -f team-b/resources-team --as=team-b-user
    ```