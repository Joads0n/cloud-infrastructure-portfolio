resource "google_compute_network" "platform" {
  name                    = var.network_settings.vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [google_project_service.platform]
}

resource "google_compute_subnetwork" "management" {
  name                     = var.network_settings.management_subnet_name
  region                   = var.platform_settings.region
  network                  = google_compute_network.platform.id
  ip_cidr_range            = var.network_settings.management_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "data" {
  name                     = var.network_settings.data_subnet_name
  region                   = var.platform_settings.region
  network                  = google_compute_network.platform.id
  ip_cidr_range            = var.network_settings.data_subnet_cidr
  private_ip_google_access = true
}

resource "google_compute_global_address" "private_services_access" {
  name          = "cedar-tfe-private-services"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  address       = cidrhost(var.network_settings.private_services_cidr, 0)
  network       = google_compute_network.platform.id
}

resource "google_service_networking_connection" "private_services_access" {
  network                 = google_compute_network.platform.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_services_access.name]
  depends_on              = [google_project_service.platform]
}
