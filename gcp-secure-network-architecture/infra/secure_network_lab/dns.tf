resource "google_dns_managed_zone" "internal" {
  provider    = google.services
  project     = local.services_project_id
  name        = "vertice-internal"
  dns_name    = var.network_settings.dns_zone_name
  description = "Zona DNS privada do serviço de pedidos e estoque."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.services.id
    }

    networks {
      network_url = google_compute_network.apps.id
    }
  }
}

resource "google_dns_record_set" "orders" {
  provider     = google.services
  project      = local.services_project_id
  managed_zone = google_dns_managed_zone.internal.name
  name         = var.network_settings.service_record_name
  type         = "A"
  ttl          = 30
  rrdatas      = [google_compute_instance.orders.network_interface[0].network_ip]
}
