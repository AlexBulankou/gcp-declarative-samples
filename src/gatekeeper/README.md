# Config Connector and Gatekeeper Integration

This sample demonstrates how you create policies to verify Config Connector objects using Gatekeeper.

1. [Provision project, cluster and Config Connector](../../provision.md)
1. Intall Gatekeeper library:
    ```bash
    kubectl apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
    ```

1. Install constraint template to `KCCAllowedResourceTypes`. It allows to specify what GCP types are allowed:
    ```bash
    kubectl apply -f templates/kccallowedresourcetypes_template.yaml
    ```

1. Install constraint that only allows `PubSubTopic` and `ComputeNetwork`:
    ```bash
    kubectl apply -f constraints/only-allowed-gcp-types.yaml
    ```

1. Try creating different objects to verify:

    - not allowed: resources/bad-service-account.yaml
    - allowed: resources/good-compute-network.yaml
    - allowed: resources/good-pubsubtopic.yaml
    - not checked: resources/not-checked-pod.yaml