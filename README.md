# blockchain-data-pipeline
This project builds scalable data pipelines for ingesting, processing, and analyzing Bitcoin and Ethereum blockchain data from AWS Public Datasets.

## Problem Statement

## Project Architecture Overview

## Step-by-Step Execution Guide
### Setup GCP
Create GCP Account, go to: https://console.cloud.google.com/
Setup New Project and write down your Project ID.
```
Project name: blockchain-data-pipeline
Project number: 711665363740
Project ID: blockchain-data-pipeline
```
Configure Service Account to get access to the project. Use the link: https://console.cloud.google.com/iam-admin/serviceaccounts
Create service account with the name: `blockchain-pipeline-sa`
Please provide the service account the permissions below (sorted by name):
```
1. BigQuery Admin
2. BigQuery Data Editor
3. BigQuery Job User
4. BigQuery User
5. Compute Admin
6. Dataproc Administrator
7. Service Account User
8. Storage Admin
9. Storage Object Admin
```
Generate private key (json) for `blockchain-pipeline-sa` and save it locally under: `~/.gcp/gcp_creds.json`

run 
```
terraform init
terraform plan
terraform apply
```
we want to automatically update VM instance external IP in the config file. We created `update_ssh_config.sh` to handle this task.
To make the script executable, run the following bash command:
```
chmod +x update_ssh_config.sh
```
Then, we can automate this by chaining it with `terraform apply`:
```bash
terraform apply -auto-approve && ./update_ssh_config.sh
```