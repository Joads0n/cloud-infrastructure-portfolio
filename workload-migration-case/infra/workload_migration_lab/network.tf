resource "google_compute_network" "target" {
  name                    = local.network_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.migration]
}

resource "google_compute_subnetwork" "target" {
  name                     = local.subnet_name
  region                   = local.region
  network                  = google_compute_network.target.id
  ip_cidr_range            = var.network_settings.subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "target" {
  name    = local.router_name
  region  = local.region
  network = google_compute_network.target.id
}

resource "google_compute_router_nat" "target" {
  name                               = local.nat_name
  router                             = google_compute_router.target.name
  region                             = local.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.target.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
