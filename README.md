# Config Connector custom samples

This repo contains a collection of infrasteucture examples using [Kubernetes Config Connector](https://github.com/GoogleCloudPlatform/k8s-config-connector).

## Simple WordPress Setup

1. Replace with your project name.

    ```bash
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/project_name_in_repo/your_project_name/g' {} \;
    ```

1. Initialize project and cluster:

    ```bash
    bash src/provision-project.sh
    bash src/provision-cluster.sh
    ```

1. Deploy:

    ```bash
    kubectl apply -f src/wp-simple/resources/
    ```

