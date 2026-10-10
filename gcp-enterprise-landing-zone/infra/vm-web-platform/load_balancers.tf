resource "google_compute_health_check" "app" {
  depends_on = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name       = local.lb_name
  http_health_check {
    port         = 80
    request_path = "/healthz"
  }
}

resource "google_compute_backend_service" "app" {
  depends_on                      = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name                            = local.vm_name
  protocol                        = "HTTP"
  port_name                       = "http"
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  health_checks                   = [google_compute_health_check.app.id]
  enable_cdn                      = false
  session_affinity                = "NONE"
  connection_draining_timeout_sec = 30
  backend {
    group           = google_compute_region_instance_group_manager.nginx.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1
    max_utilization = var.load_balancer_settings.backend_max_utilization
  }
}

resource "google_compute_url_map" "app" {
  depends_on      = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name            = local.lb_name
  default_service = google_compute_backend_service.app.id
}

resource "google_compute_target_http_proxy" "app" {
  depends_on = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  count      = var.load_balancer_settings.enable_http ? 1 : 0
  name       = local.lb_name
  url_map    = google_compute_url_map.app.id
}

resource "google_compute_global_address" "app" {
  depends_on   = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name         = local.lb_name
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

resource "google_compute_global_forwarding_rule" "app" {
  depends_on            = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  count                 = var.load_balancer_settings.enable_http ? 1 : 0
  name                  = local.lb_name
  ip_address            = google_compute_global_address.app.id
  target                = google_compute_target_http_proxy.app[0].id
  port_range            = "80"
  network_tier          = "PREMIUM"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

# TLS termina no LB; o protocolo do backend privado e das verificações de integridade continua HTTP.
resource "google_compute_target_https_proxy" "app" {
  depends_on       = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  count            = var.load_balancer_settings.enable_https ? 1 : 0
  name             = "${local.lb_name}-https"
  url_map          = google_compute_url_map.app.id
  ssl_certificates = var.load_balancer_settings.ssl_certificate_ids
}

resource "google_compute_global_forwarding_rule" "https" {
  depends_on            = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  count                 = var.load_balancer_settings.enable_https ? 1 : 0
  name                  = "${local.lb_name}-https"
  ip_address            = google_compute_global_address.app.id
  target                = google_compute_target_https_proxy.app[0].id
  port_range            = "443"
  network_tier          = "PREMIUM"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
