resource "google_compute_firewall" "lb_health_check" {
  name          = "${local.prefix}-allow-lb-health-check"
  network       = google_compute_network.target.name
  direction     = "INGRESS"
  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["lb-backend"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "iap_ssh" {
  name          = "${local.prefix}-allow-iap-ssh"
  network       = google_compute_network.target.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["iap-ssh"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
