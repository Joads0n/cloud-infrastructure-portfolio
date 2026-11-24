resource "google_compute_network" "target" {
  name                    = var.network_settings.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  depends_on = [google_project_service.migration]
}

resource "google_compute_subnetwork" "target" {
  name                     = var.network_settings.subnet_name
  region                   = var.platform_settings.region
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
  name    = var.network_settings.router_name
  region  = var.platform_settings.region
  network = google_compute_network.target.id
}

resource "google_compute_router_nat" "target" {
  name                               = var.network_settings.nat_name
  router                             = google_compute_router.target.name
  region                             = var.platform_settings.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.target.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
