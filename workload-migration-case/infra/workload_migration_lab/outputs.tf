output "source_private_ip" {
  description = "Private source fixture address."
  value       = google_compute_instance.source.network_interface[0].network_ip
}

output "target_load_balancer_ip" {
  description = "Private target load balancer address."
  value       = google_compute_forwarding_rule.target.ip_address
}

output "active_backend" {
  description = "Backend selected by the DNS cutover input."
  value       = var.migration_settings.active_backend
}

output "migration_bucket" {
  description = "Private versioned migration artifact bucket."
  value       = google_storage_bucket.migration_artifacts.name
}
