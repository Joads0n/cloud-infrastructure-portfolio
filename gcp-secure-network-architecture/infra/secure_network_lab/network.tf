resource "google_compute_network" "apps" {
  provider                = google.apps
  project                 = local.apps_project_id
  name                    = var.network_settings.apps_vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [google_project_service.apps]
}

resource "terraform_data" "network_input_contract" {
  input = {
    cidrs             = local.network_cidrs
    dns_zone_name     = var.network_settings.dns_zone_name
    service_record    = var.network_settings.service_record_name
    organization_mode = var.organization_settings.create_folder
  }

  lifecycle {
    precondition {
      condition = alltrue([
        for index, start in local.network_cidr_start_numbers : anytrue([
          start >= 167772160 && local.network_cidr_end_numbers[index] <= 184549375,
          start >= 2886729728 && local.network_cidr_end_numbers[index] <= 2887778303,
          start >= 3232235520 && local.network_cidr_end_numbers[index] <= 3232301055,
        ])
      ])
      error_message = "Os CIDRs devem permanecer inteiramente dentro de uma faixa RFC 1918."
    }

    precondition {
      condition = alltrue([
        for index, start in local.network_cidr_start_numbers : alltrue([
          for other_index, other_start in local.network_cidr_start_numbers : (
            index == other_index ||
            local.network_cidr_end_numbers[index] < other_start ||
            local.network_cidr_end_numbers[other_index] < start
          )
        ])
      ])
      error_message = "Os CIDRs das sub-redes não podem se sobrepor."
    }
  }
}

resource "google_compute_network" "services" {
  provider                = google.services
  project                 = local.services_project_id
  name                    = var.network_settings.services_vpc_name
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  depends_on              = [google_project_service.services]
}

resource "google_compute_subnetwork" "apps_application" {
  provider                 = google.apps
  project                  = local.apps_project_id
  name                     = "apps-application"
  region                   = var.platform_settings.region
  network                  = google_compute_network.apps.id
  ip_cidr_range            = var.network_settings.apps_application_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "apps_test" {
  provider                 = google.apps
  project                  = local.apps_project_id
  name                     = "apps-test"
  region                   = var.platform_settings.region
  network                  = google_compute_network.apps.id
  ip_cidr_range            = var.network_settings.apps_test_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "services" {
  provider                 = google.services
  project                  = local.services_project_id
  name                     = "services-internal"
  region                   = var.platform_settings.region
  network                  = google_compute_network.services.id
  ip_cidr_range            = var.network_settings.services_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.1
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_network_peering" "apps_to_services" {
  provider             = google.apps
  name                 = "apps-to-services"
  network              = google_compute_network.apps.self_link
  peer_network         = google_compute_network.services.self_link
  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "services_to_apps" {
  provider             = google.services
  name                 = "services-to-apps"
  network              = google_compute_network.services.self_link
  peer_network         = google_compute_network.apps.self_link
  export_custom_routes = true
  import_custom_routes = true
}
