resource "google_compute_router" "egress" {
  depends_on = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name       = "${local.prefix}-router"
  region     = local.region
  network    = google_compute_network.workload.id
}

resource "google_compute_address" "nat" {
  depends_on   = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name         = "${local.prefix}-nat"
  region       = local.region
  address_type = "EXTERNAL"
  network_tier = "PREMIUM"
  labels       = local.labels
}

resource "google_compute_router_nat" "packages" {
  depends_on                         = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name                               = "${local.prefix}-packages"
  region                             = local.region
  router                             = google_compute_router.egress.name
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = [google_compute_address.nat.self_link]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.workload.id
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }
}
