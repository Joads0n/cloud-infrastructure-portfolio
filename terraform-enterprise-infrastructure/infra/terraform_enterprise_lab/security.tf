resource "google_service_account" "runtime" {
  account_id   = "cedar-tfe-runtime"
  display_name = "Cedar Route platform fixture runtime"
  depends_on   = [google_project_service.platform]
}

resource "google_project_iam_member" "runtime_logging" {
  project = var.platform_settings.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_project_iam_member" "runtime_monitoring" {
  project = var.platform_settings.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_compute_firewall" "iap_ssh" {
  name          = "cedar-tfe-allow-iap-ssh"
  network       = google_compute_network.platform.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["os-login-managed"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "internal_http" {
  name          = "cedar-tfe-allow-management-http"
  network       = google_compute_network.platform.name
  direction     = "INGRESS"
  source_ranges = [var.network_settings.management_subnet_cidr]
  target_tags   = ["control-plane-fixture"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}
