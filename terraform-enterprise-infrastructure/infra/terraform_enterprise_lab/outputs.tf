output "fixture_private_ip" {
  description = "Private address of the control-plane fixture."
  value       = google_compute_instance.control_plane_fixture.network_interface[0].network_ip
}

output "database_private_ip" {
  description = "Private address of the Cloud SQL instance."
  value       = google_sql_database_instance.postgres.private_ip_address
}

output "artifact_bucket" {
  description = "CMEK-backed artifact bucket name."
  value       = google_storage_bucket.artifacts.name
}

output "secret_id" {
  description = "Secret Manager secret ID without a published version."
  value       = google_secret_manager_secret.tfe_encryption_key.id
}

output "kms_key_id" {
  description = "Artifact encryption key ID."
  value       = google_kms_crypto_key.artifacts.id
}
