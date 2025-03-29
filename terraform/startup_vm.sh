metadata_startup_script = <<-EOF
#!/bin/bash

echo "-------------------------START SETUP---------------------------"

# Log everything to a file for debugging
exec > /tmp/startup-script.log 2>&1
set -e

echo "Updating system..."
sudo apt update && sudo apt -y upgrade

echo "Installing dependencies..."
sudo apt-get install -y wget curl git apt-transport-https ca-certificates gnupg software-properties-common unzip

echo "Installing Anaconda..."
wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh
bash Anaconda3-2021.11-Linux-x86_64.sh -b -p $HOME/anaconda3

echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y docker.io
sudo groupadd docker
sudo gpasswd -a $USER docker
newgrp docker

# Enable Docker service
sudo systemctl enable docker
sudo systemctl start docker

echo "Installing Docker-Compose..."
mkdir -p $HOME/bin
cd $HOME/bin
wget https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -O docker-compose
chmod +x docker-compose

echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

echo "Cloning GitHub repo..."
cd $HOME
git clone https://github.com/fenniez2334/blockchain-data-pipeline.git

echo "Installing pgcli and mycli..."
conda install -c conda-forge -y pgcli
pip install -U mycli

echo "Installing Terraform..."
cd $HOME/bin
wget https://releases.hashicorp.com/terraform/1.11.3/terraform_1.11.3_linux_amd64.zip
sudo apt-get install -y unzip
unzip terraform_1.11.3_linux_amd64.zip
rm terraform_1.11.3_linux_amd64.zip

echo "Setup completed successfully!"
echo "-------------------------END SETUP---------------------------"
EOF