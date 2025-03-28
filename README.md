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
7. Editor
8. Service Account User
9. Storage Admin
10. Storage Object Admin
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

### Creating SSH config file
* In previous steps, the `update_ssh_config.sh` create config file which includes the following settings:
```
Host blockchain-dev
    HostName XX.XX.XX.XXX
    User fenniez
    IdentityFile ~/.ssh/gcp
```
* Later, use `ssh blockchain-dev` or `ssh -i ~/.ssh/gcp fenniez@externalIP ` to ssh into the google VM.
* Enable ssh with VS Code by installing Remote-SSH plugin and connecting to the remote host using the above configuration file. The instructions are .......

### Setup environment on VM
* Run this first in your SSH session: sudo apt update && sudo apt -y upgrade
* Python 3 (e.g. installed with Anaconda) -- Installing Anaconda
download and install 
Anaconda 3.12: `wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh`
Anaconda 3.9: `wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh`
Use `bash Anaconda3-2021.11-Linux-x86_64.sh` to install anaconda
use `which python` to check the location of python
* Google Cloud SDK (gcloud has already installed in gcp VM instance, use `gcloud --version` to check its existence)
* Installing Docker
use `sudo apt-get update` to fetch the list of packages, update install
next, `sudo apt-get install docker.io`
next, run Docker commands without sudo: `sudo groupadd docker` # add the docker group if it doesn't already exist
next, add the connected user $USER to the docker group: `sudo gpasswd -a $USER docker`
next, restart the docker daemon: `sudo service docker restart`
finally, test docker installation: `docker run hello-world`
* install docker-compose
Go to https://github.com/docker/compose/releases, find the lastest version `docker-compose-linux-x86_64`
create `bin` folder to put all the executable files: `mkdir bin`
go to bin, `cd bin/`
Copy the link address: `wget https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -O docker-compose`
use `chmod +x docker-compose` to make it executable
we want to execute it from any directory, add it to path variable
use `nano .bashrc` to open file, go to the end, then add the /bin directory to our path
```
export PATH="${HOME}/bin:${PATH}"
```
use `ctrl + o` to save it and `ctrl + x` to exit this file
test with `docker-compose version` to check if it is working

* clone Git repo
```
git clone https://github.com/fenniez2334/blockchain-data-pipeline.git
```

* Accessing the remote machine with VS Code and SSH remote
install `Remote - SSH` extensions in VS Code
click the `Open a Remote Window` at the left bottom of VS code
select `Connect to Host...`, then pick our VM instance name

* Installing pgcli
use `pip install pgcli` or `conda install -c conda-forge pgcli` and `pip install -U mycli`
test with `pgcli -h localhost -U root -d database_name` pgcli connect to postgres
once linked, run `\dt` to get schema

* Port-forwarding with VS code: connecting to pgAdmin and Jupyter from the local computer
go to `PORTS` section, click `forward a port`, eg: 5432 -- postgreSQL, 8080 -- pgadmin
go to the specific directory and use `jupyter notebook`, port 8888 --jupyter notebook
* Installing Terraform
Download and install Terraform by this link: https://www.terraform.io/downloads
select linux, amd64 version and copy the download link
go to `~/bin` then use `wget https://releases.hashicorp.com/terraform/1.11.3/terraform_1.11.3_linux_amd64.zip`
install unzip `sudo apt-get install unzip`
unzip it `unzip terraform_1.11.3_linux_amd64.zip`
remove zip file `rm terraform_1.11.3_linux_amd64.zip`
test with `terraform -version`

* Using sftp for putting the credentials to the remote machine
go to the local folder stores the gcp credentials `blockchain-data-pipeline/keys/gcp_creds.json`
use `sftp blockchain-dev` connect to VM blockchain-dev
`mkdir key` create key folder in VM
`put gcp_creds.json` -- upload gcp_creds.json to VM key/gcp_creds.json

* setup google application credentials:
```
export GOOGLE_APPLICATION_CREDENTIALS=~/key/gcp_creds.json
```
* use json file to authanticate our CLI
```
gcloud auth activate-service-account --key-file $GOOGLE_APPLICATION_CREDENTIALS
```




## Contact
If you have any questions or suggestions, feel free to connect with me on [Linkedin](https://www.linkedin.com/in/feifei-z-0494bba0/) or DataTalks Slack (Feifei Zhao).