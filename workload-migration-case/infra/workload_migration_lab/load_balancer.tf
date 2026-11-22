resource "google_compute_region_health_check" "target" {
  name   = "maple-target-health"
  region = var.platform_settings.region

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_region_backend_service" "target" {
  name                  = "maple-target-backend"
  region                = var.platform_settings.region
  protocol              = "TCP"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.target.id]

  backend {
    group = google_compute_region_instance_group_manager.target.instance_group
  }
}

resource "google_compute_forwarding_rule" "target" {
  name                  = "maple-target-ilb"
  region                = var.platform_settings.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.target.id
  network               = google_compute_network.target.id
  subnetwork            = google_compute_subnetwork.target.id
  ip_protocol           = "TCP"
  ports                 = ["80"]
}
