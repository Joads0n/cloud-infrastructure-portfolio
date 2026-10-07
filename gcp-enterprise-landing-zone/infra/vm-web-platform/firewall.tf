resource "google_compute_firewall" "health" {
  depends_on    = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  description   = "HTTP from Google health checks and global Application LB proxies only."
  direction     = "INGRESS"
  priority      = 1000
  name          = "${local.prefix}-health-http"
  network       = google_compute_network.workload.id
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["${local.prefix}-nginx"]
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "iap" {
  depends_on    = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  description   = "SSH from IAP TCP forwarding only; OS Login and IAM are separate requirements."
  direction     = "INGRESS"
  priority      = 1000
  name          = "${local.prefix}-iap-ssh"
  network       = google_compute_network.workload.id
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["${local.prefix}-nginx"]
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "deny_ingress" {
  depends_on    = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name          = "${local.prefix}-deny-other-ingress"
  description   = "Explicit backend ingress boundary after the narrow allow rules."
  network       = google_compute_network.workload.id
  direction     = "INGRESS"
  priority      = 2000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${local.prefix}-nginx"]
  deny {
    protocol = "all"
  }
}

resource "google_compute_firewall" "web_egress" {
  depends_on         = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name               = "${local.prefix}-web-egress"
  network            = google_compute_network.workload.id
  direction          = "EGRESS"
  priority           = 900
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["${local.prefix}-nginx"]
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

resource "google_compute_firewall" "deny_egress" {
  depends_on         = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name               = "${local.prefix}-deny-other-egress"
  network            = google_compute_network.workload.id
  direction          = "EGRESS"
  priority           = 1000
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = ["${local.prefix}-nginx"]
  deny {
    protocol = "all"
  }
}
