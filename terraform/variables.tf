variable "project_id" {
  type        = string
  description = "The ID of the GCP project to create resources in."
}

variable "region" {
  type        = string
  description = "The GCP region to create resources in."
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "The GCP zone to create resources in."
  default     = "us-central1-c"
}

variable "machine_type" {
  type        = string
  description = "The machine type for the VMs."
  default     = "e2-medium"
}

variable "image" {
  type        = string
  description = "The boot disk image for the VMs."
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "service_account_id" {
  type        = string
  description = "The ID for the custom service account."
  default     = "task-sa"
}