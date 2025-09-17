resource "google_service_account" "default" {
  account_id   = "task-sa"
  display_name = "SA for VM instances"
}

resource "google_compute_address" "ip_address" {
  name   = "my-address"
  region = "us-central1"
}

resource "google_compute_instance" "ops" {
  name         = "ops-instance"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"

  tags = ["builder-vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    
    # Update package list
    sudo apt-get update
    
    # Install Git, OpenJDK (Java), and Maven
    sudo apt-get install -y git openjdk-11-jdk maven
    
    # You can also add commands here to clone your repository,
    # build the project, and deploy the artifact.
    # For example:
    # git clone https://github.com/your-repo/your-project.git
    # cd your-project
    # mvn clean package
    EOT

  service_account {
    email  = "503214801602-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_firewall" "allow-ssh-from-internet" {
  name    = "allow-ssh-to-builder-vm"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Allows SSH from any IP address.
  target_tags   = ["builder-vm"]
}
