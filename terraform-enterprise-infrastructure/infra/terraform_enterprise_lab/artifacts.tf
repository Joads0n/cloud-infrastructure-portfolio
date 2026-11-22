data "google_project" "current" {
  project_id = var.platform_settings.project_id
}

resource "google_kms_key_ring" "platform" {
  name     = var.artifacts_settings.key_ring_name
  location = var.platform_settings.region
}

resource "google_kms_crypto_key" "artifacts" {
  name            = var.artifacts_settings.key_name
  key_ring        = google_kms_key_ring.platform.id
  rotation_period = "7776000s"
}

resource "google_secret_manager_secret" "tfe_encryption_key" {
  secret_id = "cedar-tfe-encryption-key"
  replication {
    auto {}
  }
}

resource "google_storage_bucket" "artifacts" {
  name                        = var.artifacts_settings.bucket_name
  location                    = var.platform_settings.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = false

  versioning {
    enabled = true
  }

  retention_policy {
    retention_period = var.artifacts_settings.retention_days * 86400
  }

  encryption {
    default_kms_key_name = google_kms_crypto_key.artifacts.id
  }
}

resource "google_kms_crypto_key_iam_member" "storage_service_agent" {
  crypto_key_id = google_kms_crypto_key.artifacts.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}

resource "google_kms_crypto_key_iam_member" "runtime" {
  crypto_key_id = google_kms_crypto_key.artifacts.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.runtime.email}"
}

resource "google_storage_bucket_iam_member" "runtime" {
  bucket = google_storage_bucket.artifacts.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.runtime.email}"
}
