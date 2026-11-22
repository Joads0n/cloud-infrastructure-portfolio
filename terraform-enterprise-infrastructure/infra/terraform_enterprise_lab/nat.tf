resource "google_compute_router" "platform" {
  name    = "cedar-tfe-router"
  region  = var.platform_settings.region
  network = google_compute_network.platform.id
}

resource "google_compute_router_nat" "platform" {
  name                               = "cedar-tfe-nat"
  router                             = google_compute_router.platform.name
  region                             = var.platform_settings.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.management.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
