1. Replace with your project name and billing account:

    ```bash
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/\[PROJECT_ID\]/your_project_id/g' {} \;
    LC_CTYPE=C && find ./src/ -type f -exec sed -i '' 's/\[BILLING_ACCOUNT\]/your_billing_account/g' {} \;
    ```
1. Initialize project and cluster:

    ```bash
    bash src/provision.sh
    ```