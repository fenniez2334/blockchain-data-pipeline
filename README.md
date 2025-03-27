# blockchain-data-pipeline
This project builds scalable data pipelines for ingesting, processing, and analyzing Bitcoin and Ethereum blockchain data from AWS Public Datasets.

## Problem Statement

## Project Architecture Overview

## Step-by-Step Execution Guide
### Clone this Git Repository
To ensure smooth reproducibility of this project, I recommend following the steps below:
1. Step 1: Use a Linux-Compatible Environment
* Run the following steps in a GitBash or MinGW terminal to ensure that the process runs in a Linux-like environment.
* If you are using a Windows system, download and install Git Bash from https://git-scm.com/downloads
2. Step 2: Clone the Repository
* Open a git bash terminal and navigate to your home directory `cd ~` 
* clone this github repository under your home directory 
```
git clone https://github.com/fenniez2334/blockchain-data-pipeline.git
```
3. Step 3: Navigate to project directory
```
cd blockchain-data-pipeline
```

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
* Enable these APIs for your project:
- https://console.cloud.google.com/apis/library/iam.googleapis.com
- https://console.cloud.google.com/apis/library/iamcredentials.googleapis.com

### Set Up Google Cloud Service Account Credentials
1. Step 1: Access Google Cloud Console
* Go to https://console.cloud.google.com/iam-admin/serviceaccounts
* Locate and select your service account `blockchain-pipeline-sa` 
2. Step 2: Generate a New Key
* Under the `keys` section: click on `add key` --> select `create new key` --> choose `JSON` as key type --> click `create`
3. Step 3: Download and Rename the Key
* Download the Service Account credential file, rename it to `gcp_creds.json`
4. Step 4: Move the Key to the Project Directory
* Place the renamed key file in the following directory within your project: 
```
blockchain-data-pipeline/keys/gcp_creds.json
```
5. Step 5: Set environment variable to point to your downloaded GCP keys:
```
export GOOGLE_APPLICATION_CREDENTIALS="<path/to/your/service-account-authkeys>.json"

# Refresh token/session, and verify authentication
gcloud auth application-default login
```


### Terraform as Infrastructure-as-Code(IaC) Tool
* Download and install Terraform by this link: https://www.terraform.io/downloads
* Put it to a folder in `PATH`, check this instruction: https://gist.github.com/nex3/c395b2f8fd4b02068be37c961301caa7
* navigate to your home directory `cd ~` 
* located to `terraform` folder using `cd blockchain-data-pipeline` and `cd terraform`
* `main.td` will automatically generate the following resouces:
```
1. Google Provider Versions
2. resource "google_storage_bucket"
3. resource "google_bigquery_dataset"
4. resource "google_compute_instance"
5. output "vm_external_ip"
```
* execute the following steps:
1. `terraform init`: Initializes & configures the backend, installs plugins/providers, & checks out an existing configuration from a version control
2. `terraform plan`: Matches/previews local changes against a remote state, and proposes an Execution Plan.
3. `terraform apply`: Asks for approval to the proposed plan, and applies changes to cloud


* To automatically update VM instance external IP in the config file. I created `update_ssh_config.sh` to handle this task.
* To make the script executable, run the following bash command:
```
chmod +x update_ssh_config.sh
```
* Then, we can automate this by chaining it with `terraform apply`:
```bash
terraform apply -auto-approve && ./update_ssh_config.sh
```
* Once you successfully reproduce this project and you would like to remove your stack from the Cloud, use the `terraform destroy` command.


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
* In previous steps, the `update_ssh_config.sh` create config file which includes the following settings:
```
Host blockchain-dev
    HostName XX.XX.XX.XXX
    User fenniez
    IdentityFile ~/.ssh/gcp
```
* Later, use `ssh blockchain-dev` to ssh into the google VM.
* Enable ssh with VS Code by installing Remote-SSH plugin and connecting to the remote host using the above configuration file. The instructions are .......

### Setup environment on VM





## Contact
If you have any questions or suggestions, feel free to connect with me on [Linkedin](https://www.linkedin.com/in/feifei-z-0494bba0/) or DataTalks Slack (Feifei Zhao).