resource "google_compute_instance" "cloud_service" {
  count        = var.compute_settings.enabled ? 1 : 0
  name         = var.compute_settings.name
  zone         = var.platform_settings.zone
  machine_type = var.compute_settings.machine_type

  network_interface {
    subnetwork = google_compute_subnetwork.cloud.id
  }

  boot_disk {
    initialize_params {
      image = var.compute_settings.image
      size  = 10
      type  = "pd-standard"
    }
  }

  metadata_startup_script = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y nginx
    printf '%s\n' 'Orion private hybrid service' > /var/www/html/index.html
    systemctl enable --now nginx
  SCRIPT

  service_account {
    scopes = ["https://www.googleapis.com/auth/logging.write"]
  }

  labels = merge(local.common_labels, { role = "cloud-service" })
}
