resource "google_compute_router" "apps" {
  provider = google.apps
  project  = local.apps_project_id
  name     = "apps-router"
  region   = var.platform_settings.region
  network  = google_compute_network.apps.id
}

resource "google_compute_router_nat" "apps" {
  provider                           = google.apps
  project                            = local.apps_project_id
  name                               = "apps-nat"
  router                             = google_compute_router.apps.name
  region                             = var.platform_settings.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.apps_application.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  subnetwork {
    name                    = google_compute_subnetwork.apps_test.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_compute_router" "services" {
  provider = google.services
  project  = local.services_project_id
  name     = "services-router"
  region   = var.platform_settings.region
  network  = google_compute_network.services.id
}

resource "google_compute_router_nat" "services" {
  provider                           = google.services
  project                            = local.services_project_id
  name                               = "services-nat"
  router                             = google_compute_router.services.name
  region                             = var.platform_settings.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.services.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
