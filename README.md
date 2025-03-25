# blockchain-data-pipeline
This project builds scalable data pipelines for ingesting, processing, and analyzing Bitcoin and Ethereum blockchain data from AWS Public Datasets.

## Problem Statement

## Project Architecture Overview

## Step-by-Step Execution Guide
### Setup GCP
* Create GCP Account, go to: https://console.cloud.google.com/
* Setup New Project and write down your Project ID.
```
Project name: blockchain-data-pipeline
Project number: 711665363740
Project ID: blockchain-data-pipeline
```
* Configure Service Account to get access to the project. Use the link: https://console.cloud.google.com/iam-admin/serviceaccounts
* Create service account with the name: `blockchain-pipeline-sa`
* Please provide the service account the permissions below (sorted by name):
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
* Generate private key (json) for `blockchain-pipeline-sa` and save it locally under: `~/.gcp/gcp_creds.json`

run 
```
terraform init
terraform plan
terraform apply
```
* If you would like to remove your stack from the Cloud, use the `terraform destroy` command.
* we want to automatically update VM instance external IP in the config file. We created `update_ssh_config.sh` to handle this task.
* To make the script executable, run the following bash command:
```
chmod +x update_ssh_config.sh
```
* Then, we can automate this by chaining it with `terraform apply`:
```bash
terraform apply -auto-approve && ./update_ssh_config.sh
```

### Setup SSH access into VM
* Use Git Bash to open terminal on your local laptop in Linux environment
* first navigate to the ssh directory
```
cd .ssh/
```
* create a new ssh key
```
ssh-keygen -t rsa -f gcp -C fenniez -b 2048
```
* This command will generate one public key `gcp.pub` and one private key `gcp`
* put this public key `gcp.pub` to google cloud, go to Compute Engine --> Meta data --> ssh keys
* Use the command in the bash terminal to print the public key
```
cat gcp.pub
```
* username: fenniez
* key is our generated public key + username at the end
* copy this key and paste it in `google cloud ssh keys` and click `save` botton.
* create config file which includes the following settings:
```
Host blockchain-dev
    HostName XX.XX.XX.XXX
    User fenniez
    IdentityFile ~/.ssh/gcp
```
* Later, use `ssh blockchain-dev` to ssh into the google VM.
* Enable ssh with VS Code by installing Remote-SSH plugin and connecting to the remote host using the above configuration file. The instructions are .......

### Setup environment on VM