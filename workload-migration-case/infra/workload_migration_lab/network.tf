resource "google_compute_network" "source" {
  name                    = var.network_settings.source_vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [google_project_service.migration]
}

resource "google_compute_network" "target" {
  name                    = var.network_settings.target_vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [google_project_service.migration]
}

resource "google_compute_subnetwork" "source" {
  name                     = var.network_settings.source_subnet_name
  region                   = var.platform_settings.region
  network                  = google_compute_network.source.id
  ip_cidr_range            = var.network_settings.source_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "target" {
  name                     = var.network_settings.target_subnet_name
  region                   = var.platform_settings.region
  network                  = google_compute_network.target.id
  ip_cidr_range            = var.network_settings.target_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
