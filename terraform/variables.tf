variable "credentials" {
  description = "Project credentials"
  default = "../keys/gcp-creds.json"
}

variable "project" {
  description = "Project Name"
  default = "blockchain-data-pipeline"
}

variable "region" {
  description = "Project Region"
  default = "us-central1"
}

variable "location" {
  description = "Project Location"
  default = "US"
}

variable "bq_dataset_name" {
  description = "My BigQuery Dataset Name"
  default = "bc_dataset"
}

variable "gcs_bucket_name" {
  description = "Bucket Storage Bucket Name"
  default = "blockchain-data-pipeline-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default = "STANDARD"
}

variable "gcs_service_account_name" {
  description = "Service Account Name"
  default = "blockchain-pipeline-sa"
}

variable "gcs_instance_name" {
  description = "VM Instance Name"
  default = "blockchain-dev"
}

variable "instance_machine_type" {
  description = "Instance Machine Type"
  default = "e2-standard-4"
}

variable "boot_disk_image_type" {
  description = "Boot Disk Image Type"
  default = "ubuntu-os-cloud/ubuntu-2004-focal-v20250111"
}

variable "privatekeypath" {
  type    = string
  default = "~/.ssh/gcp"
}
variable "publickeypath" {
  type    = string
  default = "~/.ssh/gcp.pub"
}
variable "repo_url" {
  type    = string
  default = "https://github.com/fenniez2334/blockchain-data-pipeline.git"
}
variable "user" {
  type    = string
  default = "fenniez"

}
