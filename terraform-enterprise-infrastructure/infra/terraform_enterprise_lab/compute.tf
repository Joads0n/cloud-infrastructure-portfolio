resource "google_compute_instance" "control_plane_fixture" {
  name         = "cedar-tfe-control-plane-fixture"
  zone         = var.platform_settings.zone
  machine_type = "e2-micro"
  tags         = ["control-plane-fixture", "os-login-managed"]
  metadata = {
    enable-oslogin = "TRUE"
  }

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-12"
      size  = 10
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.management.id
  }

  metadata_startup_script = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y nginx
    printf '%s\n' 'Cedar Route Terraform platform fixture; not Terraform Enterprise.' > /var/www/html/index.html
    systemctl enable --now nginx
  SCRIPT

  service_account {
    email = google_service_account.runtime.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  labels     = merge(local.common_labels, { role = "control-plane-fixture" })
  depends_on = [google_project_iam_member.runtime_logging, google_project_iam_member.runtime_monitoring]
}
