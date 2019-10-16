# GCR image pull permissions from exernal K8s cluster with Config Connector

This sample demonstrates how you can provision a secret on external K8s clusters for GCR image using Config Connector

1. Update the files in this example to use your project name
    ```
    LC_CTYPE=C && find ./resources/ -type f -exec sed -i '' 's/\[PROJECT_ID\]/your_project_id/g' {} \;
    ```

1. Create cluster on your favorite non-GCP cloud provider. For example, [create Amazon EKS cluster](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html)
1. Create GCP project and install Config Connector on your cluster:

    ```
    export PROJECT_ID=[PROJECT_ID]
    export SA_EMAIL="cnrm-system@${PROJECT_ID}.iam.gserviceaccount.com"

    # create project
    gcloud projects create $PROJECT_ID --name="$PROJECT_ID"
    gcloud config set project $PROJECT_ID

    # to provision Config Connector, create cnrm-system service account and export the tkey
    gcloud iam service-accounts create cnrm-system --project ${PROJECT_ID}
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member "serviceAccount:${SA_EMAIL}" --role roles/owner
    gcloud iam service-accounts keys create --iam-account "${SA_EMAIL}" ./key.json

    # install Config Connector
    kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)
    curl -X GET -sLO --location-trusted https://us-central1-cnrm-eap.cloudfunctions.net/download/latest/infra/install-bundle.tar.gz
    rm -rf install-bundle
    tar zxvf install-bundle.tar.gz
    kubectl apply -f install-bundle/

    # give cnrm-system namespace permissions to manage GCP
    kubectl create secret generic gcp-key --from-file ./key.json --namespace cnrm-system

    # annotate the namespace
    kubectl annotate namespace default "cnrm.cloud.google.com/project-id=${PROJECT_ID}" --overwrite
    ```
1. Create your GCR bucket: 
    ```
    kubectl apply -f ./resources/gcr-bucket.yaml
    ```
1. Upload the image to your GCR bucket. For example, using my name:
    ```
    docker pull bulankou/node-hello-world:latest
    docker tag bulankou/node-hello-world gcr.io/[PROJECT_ID]/node-hello-world
    docker push gcr.io/[PROJECT_ID]/node-hello-world
    ```

1. Create resources, including service account, service account key, IAM policy for the service account and GCR bucket.
    ```
    kubectl apply -f ./resources/
    ```

1. Create `gcr-docker-key` secret to pull the image. It is using `gcr-sa-key` that was automatically created by Config Connector.
    ```
    kubectl create secret docker-registry gcr-docker-key \
    --docker-server=https://gcr.io \
    --docker-username=_json_key \
    --docker-email=user@example.com \
    --docker-password="$(kubectl get secret gcr-sa-key -o go-template=$'{{index .data "key.json"}}' | base64 --decode)"
    ```
1. Verify that pod is created:
    ```
    kubectl get pods
    kubectl exec node-app-pod curl http://localhost:8080
    ```
