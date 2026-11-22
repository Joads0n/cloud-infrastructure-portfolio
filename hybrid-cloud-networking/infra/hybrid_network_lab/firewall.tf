resource "google_compute_firewall" "cloud_ingress_from_peer" {
  name          = "orion-cloud-allow-peer-https"
  network       = google_compute_network.cloud.name
  direction     = "INGRESS"
  source_ranges = [var.network_settings.peer_advertised_cidr]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}

resource "google_compute_firewall" "peer_fixture_ingress" {
  name          = "orion-peer-allow-cloud-https"
  network       = google_compute_network.peer_fixture.name
  direction     = "INGRESS"
  source_ranges = [var.network_settings.cloud_subnet_cidr]

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
}
