#!/bin/bash

echo "-------------------------START SETUP---------------------------"

echo "Updating system..."
sudo apt-get update
# sudo apt update && sudo apt -y upgrade

echo "Installing dependencies..."
sudo apt-get install -y wget curl git apt-transport-https ca-certificates gnupg software-properties-common unzip

echo "Installing Anaconda..."
cd $HOME
wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh
bash Anaconda3-2021.11-Linux-x86_64.sh -b -p $HOME/anaconda3
# Initialize Anaconda after batch install
echo "Initializing Anaconda..."
$HOME/anaconda3/bin/conda init
# Reload bashrc to apply changes
source ~/.bashrc
rm Anaconda3-2021.11-Linux-x86_64.sh

sleep 20

echo "Installing Docker..."
sudo apt-get install -y docker.io
sudo groupadd docker
sudo gpasswd -a $USER docker

sleep 10

echo "Installing Docker-Compose..."
mkdir -p $HOME/bin
cd $HOME/bin
wget https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64 -O docker-compose
chmod +x docker-compose

echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc

sleep 10

echo "Installing Terraform..."
cd $HOME/bin
wget https://releases.hashicorp.com/terraform/1.11.3/terraform_1.11.3_linux_amd64.zip
unzip terraform_1.11.3_linux_amd64.zip
rm terraform_1.11.3_linux_amd64.zip

sleep 10

echo "Installing Java 11..."
cd $HOME
mkdir -p ~/spark && cd ~/spark
wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
tar xzfv openjdk-11.0.2_linux-x64_bin.tar.gz
echo 'export JAVA_HOME="$HOME/spark/jdk-11.0.2"' >> ~/.bashrc
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
rm openjdk-11.0.2_linux-x64_bin.tar.gz

sleep 10

echo "Installing Spark..."
cd $HOME/spark
wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz
tar xzfv spark-3.3.2-bin-hadoop3.tgz
echo 'export SPARK_HOME="$HOME/spark/spark-3.3.2-bin-hadoop3"' >> ~/.bashrc
echo 'export PATH="$SPARK_HOME/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
rm spark-3.3.2-bin-hadoop3.tgz

sleep 10

echo "Setup PySpark..."
echo 'export PYTHONPATH="$SPARK_HOME/python/:$PYTHONPATH"' >> ~/.bashrc
echo 'export PYTHONPATH="$SPARK_HOME/python/lib/py4j-0.10.9.5-src.zip:$PYTHONPATH"' >> ~/.bashrc
source ~/.bashrc

echo "Setup completed successfully!"
echo "-------------------------END SETUP---------------------------"