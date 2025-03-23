variable "credentials" {
  description = "Project credentials"
  default = "./keys/my-creds.json"
}

variable "project" {
  description = "Project Name"
  default = "central-beach-447906-q6"
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
  default = "demo_dataset"
}

variable "gcs_bucket_name" {
  description = "Bucket Storage Bucket Name"
  default = "central-beach-447906-q6-terra-bucket"
}

variable "gcs_storage_class" {
  description = "Bucket Storage Class"
  default = "STANDARD"
}