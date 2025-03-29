terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.17.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials)
  # Configuration options
  project = var.project
  region  = var.region

}


resource "google_storage_bucket" "gcp-bucket" {
  name          = var.gcs_bucket_name
  location      = var.location
  force_destroy = true


  lifecycle_rule {
    condition {
      # this age is used in days  
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}

resource "google_bigquery_dataset" "gcp_dataset" {
  dataset_id = var.bq_dataset_name
  location = var.location
}


# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name       = "vm-public-address"
  project    = var.project
  region     = var.region
  depends_on = [google_compute_firewall.ssh]
}

resource "google_compute_network" "vpc_network" {
  name = "my-network"
}


resource "google_compute_instance" "blockchain-dev" {
  name         = var.gcs_instance_name
  machine_type = var.instance_machine_type
  zone         = "${var.region}-f"

  # Add tags to allow traffic through the firewall
  tags = ["ssh"]  # Add this line to match the firewall target_tags

  // Create a new boot disk from an image
  boot_disk {
    initialize_params {
      image = var.boot_disk_image_type  # Ubuntu 20.04 LTS image
      size  = 40                                             # Disk size in GB
      type  = "pd-balanced"                                  # Balanced persistent disk
    }
  }

  network_interface {
    network    = "default"                         # Default VPC network
    subnetwork = "default"                         # Default subnet
    network_ip = null                     # Primary internal IP address
    access_config {
      // Assigning ephemeral external IP
      nat_ip       = google_compute_address.static.address
      network_tier = "PREMIUM"                     # Network tier
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "${var.gcs_service_account_name}@${var.project}.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  scheduling {
    automatic_restart   = true                         # Auto-restart on failure
    on_host_maintenance = "MIGRATE"                    # Migrate on maintenance
  }

  shielded_instance_config {
    enable_secure_boot          = false                # Secure Boot is off
    enable_vtpm                 = true                 # vTPM is enabled
    enable_integrity_monitoring = true                 # Integrity monitoring is enabled
  }

  deletion_protection = false                           # Deletion protection is disabled

  # Ensure firewall rule is provisioned before server, so that SSH doesn't fail.
  depends_on = [google_compute_firewall.ssh]

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
  }


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

}




resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.name
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

output "vm_external_ip" {
  description = "External IP address of the VM instance"
  value       = google_compute_instance.blockchain-dev.network_interface[0].access_config[0].nat_ip
}