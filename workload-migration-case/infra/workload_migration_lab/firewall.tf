resource "google_compute_firewall" "source_http" {
  name          = "maple-source-allow-http"
  network       = google_compute_network.source.name
  direction     = "INGRESS"
  source_ranges = [var.network_settings.source_subnet_cidr, var.network_settings.target_subnet_cidr]
  target_tags   = ["legacy-source"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "target_health" {
  name          = "maple-target-allow-health"
  network       = google_compute_network.target.name
  direction     = "INGRESS"
  source_ranges = [var.network_settings.target_subnet_cidr]
  target_tags   = ["migration-target"]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "iap_ssh" {
  name          = "maple-migration-allow-iap-ssh"
  network       = google_compute_network.target.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["migration-target"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
