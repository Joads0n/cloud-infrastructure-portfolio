resource "google_compute_network" "cloud" {
  name                    = var.network_settings.cloud_vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_network" "peer_fixture" {
  name                    = var.network_settings.peer_vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "cloud" {
  name                     = "orion-cloud-application"
  region                   = var.platform_settings.region
  network                  = google_compute_network.cloud.id
  ip_cidr_range            = var.network_settings.cloud_subnet_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "peer_fixture" {
  name                     = "orion-peer-warehouse"
  region                   = var.platform_settings.region
  network                  = google_compute_network.peer_fixture.id
  ip_cidr_range            = var.network_settings.peer_subnet_cidr
  private_ip_google_access = true
}
