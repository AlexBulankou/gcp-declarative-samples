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
