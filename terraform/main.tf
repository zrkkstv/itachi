# Creating network
resource "google_compute_network" "main" {
  name = "dev-network"
}

# Defines a custom service account
resource "google_service_account" "task_sa" {
  account_id   = var.service_account_id
  display_name = "SA for VM instances"
}

# The OpS for building the application
resource "google_compute_instance" "ops_server" {
  name         = "ops-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "dev-network"
    access_config {}
  }

  service_account {
    email  = google_service_account.task_sa.email
    scopes = ["cloud-platform"]
  }

  tags = ["builder-vm", "http-server"]
}

# The ApS for running the application
resource "google_compute_instance" "aps_server" {
  name         = "aps-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = "dev-network"
    access_config {}
  }

  service_account {
    email  = google_service_account.task_sa.email
    scopes = ["cloud-platform"]
  }

  tags = ["app-server", "http-server"]
}

# A storage bucket to hold build artifacts
resource "google_storage_bucket" "artifacts_bucket" {
  name     = "${var.project_id}-app-artifacts"
  location = var.region
}

# Firewall rule to allow SSH from the internet to builder and app servers
resource "google_compute_firewall" "allow-ssh" {
  name        = "allow-ssh-from-internet"
  network     = "dev-network"
  target_tags = ["builder-vm", "app-server"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# Firewall rule to allow HTTP from the internet
resource "google_compute_firewall" "allow-http" {
  name        = "allow-http-from-internet"
  network     = "dev-network"
  target_tags = ["app-server"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
}