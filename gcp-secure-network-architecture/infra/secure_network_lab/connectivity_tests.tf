resource "google_network_management_connectivity_test" "application_to_orders" {
  count    = var.test_settings.enabled ? 1 : 0
  provider = google.services
  project  = local.services_project_id
  name     = "application-to-orders-http"

  source {
    instance = google_compute_instance.application.id
  }

  destination {
    instance = google_compute_instance.orders.id
    port     = var.test_settings.port
  }

  protocol = "TCP"
  labels   = merge(local.common_labels, { test = "allowed-path" })
}

resource "google_network_management_connectivity_test" "test_to_orders" {
  count    = var.test_settings.enabled ? 1 : 0
  provider = google.services
  project  = local.services_project_id
  name     = "test-to-orders-http"

  source {
    instance = google_compute_instance.test.id
  }

  destination {
    instance = google_compute_instance.orders.id
    port     = var.test_settings.port
  }

  protocol = "TCP"
  labels   = merge(local.common_labels, { test = "blocked-path" })
}
