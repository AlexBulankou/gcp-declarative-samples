# GCP Project and Config Connector cluster provisioning

* Authenticate to GCP

```bash
gcloud auth application-default login
```

* Create project and cluster with Config Connector enabled:

```bash
terraform apply -var="project=PROJECT_ID"       \
                -var="folder_id=FOLDER_ID"      \
                -var="billing_account=BILLING_ACCOUNT"
```

* Set the context

```bash
gcloud config set project [project_id]
gcloud container clusters get-credentials cluster-1 --zone=[zone]
```

```bash
helm install ./config-connector-resource/. --set [project_id] --generate-name
kubectl annotate namespace default cnrm.cloud.google.com/[project_id]
```
