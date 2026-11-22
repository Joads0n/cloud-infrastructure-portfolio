resource "google_service_account" "source_runtime" {
  account_id   = "maple-source-runtime"
  display_name = "Maple legacy source fixture runtime"
  depends_on   = [google_project_service.migration]
}

resource "google_service_account" "target_runtime" {
  account_id   = "maple-target-runtime"
  display_name = "Maple migration target runtime"
  depends_on   = [google_project_service.migration]
}

resource "google_project_iam_member" "source_logging" {
  project = var.platform_settings.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.source_runtime.email}"
}

resource "google_project_iam_member" "target_logging" {
  project = var.platform_settings.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.target_runtime.email}"
}

resource "google_compute_instance" "source" {
  name         = "maple-legacy-source"
  zone         = var.platform_settings.zone
  machine_type = "e2-micro"
  tags         = ["legacy-source", "os-login-managed"]
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
    subnetwork = google_compute_subnetwork.source.id
  }

  metadata_startup_script = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y nginx
    printf '%s\n' 'Maple legacy source fixture' > /var/www/html/index.html
    systemctl enable --now nginx
  SCRIPT

  service_account {
    email  = google_service_account.source_runtime.email
    scopes = ["https://www.googleapis.com/auth/logging.write"]
  }

  labels     = merge(local.common_labels, { role = "legacy-source" })
  depends_on = [google_project_iam_member.source_logging]
}

resource "google_compute_instance_template" "target" {
  name_prefix  = "maple-target-"
  machine_type = "e2-micro"
  tags         = ["migration-target"]

  disk {
    source_image = "projects/debian-cloud/global/images/family/debian-12"
    boot         = true
    disk_size_gb = 10
    disk_type    = "pd-standard"
  }

  network_interface {
    subnetwork = google_compute_subnetwork.target.id
  }

  metadata_startup_script = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y nginx
    printf '%s\n' 'Maple migration target fixture' > /var/www/html/index.html
    systemctl enable --now nginx
  SCRIPT

  service_account {
    email  = google_service_account.target_runtime.email
    scopes = ["https://www.googleapis.com/auth/logging.write"]
  }

  labels = merge(local.common_labels, { role = "migration-target" })
}

resource "google_compute_region_instance_group_manager" "target" {
  name               = "maple-target-mig"
  region             = var.platform_settings.region
  base_instance_name = "maple-target"
  target_size        = var.migration_settings.target_size

  version {
    instance_template = google_compute_instance_template.target.id
  }

  named_port {
    name = "http"
    port = 80
  }
}
