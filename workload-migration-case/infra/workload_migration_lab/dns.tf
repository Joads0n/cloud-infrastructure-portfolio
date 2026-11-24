resource "google_dns_managed_zone" "migration" {
  name        = local.dns_zone_name
  dns_name    = local.dns_name
  description = "Zona DNS fictícia para exercitar o cutover e rollback das VMs AWS para GCP."
  visibility  = "public"

  depends_on = [google_project_service.migration]
}

resource "google_dns_record_set" "active_backend" {
  managed_zone = google_dns_managed_zone.migration.name
  name         = local.record_name
  type         = "A"
  ttl          = var.cutover_settings.ttl
  rrdatas = [
    var.cutover_settings.active_backend == "gcp" ? google_compute_global_address.target.address : var.cutover_settings.fictional_source_ip
  ]
}
