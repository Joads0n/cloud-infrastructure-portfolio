resource "google_compute_network" "workload" {
  depends_on              = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name                    = coalesce(var.network_settings.vpc_name, "${local.prefix}-vpc")
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "workload" {
  depends_on               = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name                     = coalesce(var.network_settings.subnet_name, "${local.prefix}-subnet")
  region                   = local.region
  network                  = google_compute_network.workload.id
  ip_cidr_range            = local.subnet
  private_ip_google_access = true
}
