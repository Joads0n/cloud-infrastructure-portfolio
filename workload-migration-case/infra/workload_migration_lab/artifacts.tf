resource "google_storage_bucket" "migration_artifacts" {
  name                        = var.migration_settings.artifact_bucket_name
  location                    = var.platform_settings.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  retention_policy {
    retention_period = var.migration_settings.artifact_retention_days * 86400
  }
}

resource "google_storage_bucket_iam_member" "target_writer" {
  bucket = google_storage_bucket.migration_artifacts.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.target_runtime.email}"
}
