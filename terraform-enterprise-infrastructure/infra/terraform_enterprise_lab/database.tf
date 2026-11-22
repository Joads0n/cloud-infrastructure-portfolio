resource "google_sql_database_instance" "postgres" {
  name                = var.database_settings.name
  database_version    = var.database_settings.database_version
  region              = var.platform_settings.region
  deletion_protection = false

  settings {
    tier              = var.database_settings.tier
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 20

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
        retention_unit   = "COUNT"
      }
    }

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.platform.id
      enable_private_path_for_google_cloud_services = true
    }
  }

  depends_on = [google_service_networking_connection.private_services_access]
}

resource "google_sql_database" "terraform_enterprise" {
  name     = var.database_settings.database_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "runtime" {
  name     = var.database_settings.user_name
  instance = google_sql_database_instance.postgres.name
  password = var.database_settings.password
}
