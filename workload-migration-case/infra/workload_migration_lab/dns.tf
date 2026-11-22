resource "google_dns_managed_zone" "migration" {
  name        = "maple-migration-internal"
  dns_name    = var.network_settings.dns_zone_name
  description = "Private DNS switch for the synthetic migration exercise."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.source.id
    }

    networks {
      network_url = google_compute_network.target.id
    }
  }
}

resource "google_dns_record_set" "active_backend" {
  managed_zone = google_dns_managed_zone.migration.name
  name         = var.network_settings.dns_record_name
  type         = "A"
  ttl          = 30
  rrdatas = [
    var.migration_settings.active_backend == "target" ? google_compute_forwarding_rule.target.ip_address : google_compute_instance.source.network_interface[0].network_ip
  ]
}
