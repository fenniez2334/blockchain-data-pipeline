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
  
  # Ensure firewall rule is provisioned before server, so that SSH doesn't fail.
  depends_on = [google_compute_firewall.ssh]

  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
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