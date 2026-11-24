resource "google_compute_global_address" "target" {
  name = "maple-m2vm-global-ip"
}

resource "google_compute_health_check" "target" {
  name = "maple-m2vm-health-check"

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

resource "google_compute_backend_service" "target" {
  name                  = "maple-m2vm-global-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.target.id]

  backend {
    group           = google_compute_instance_group.target.id
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "target" {
  name            = "maple-m2vm-url-map"
  default_service = google_compute_backend_service.target.id
}

resource "google_compute_target_http_proxy" "target" {
  name    = "maple-m2vm-http-proxy"
  url_map = google_compute_url_map.target.id
}

resource "google_compute_global_forwarding_rule" "target" {
  name                  = "maple-m2vm-http-forwarding-rule"
  target                = google_compute_target_http_proxy.target.id
  ip_address            = google_compute_global_address.target.id
  port_range            = "80"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "PREMIUM"
}
