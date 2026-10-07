# Vinculada pelo template para que VMs adicionadas/recriadas herdem o agendamento.
resource "google_compute_resource_policy" "daily_snapshot" {
  depends_on = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  name       = "${local.prefix}-daily-snapshot"
  region     = local.region
  snapshot_schedule_policy {
    schedule {
      daily_schedule {
        days_in_cycle = 1
        # UTC; o exemplo 05:00 corresponde à janela de início 02:00-03:00 em Fortaleza.
        start_time = var.snapshot_settings.start_time
      }
    }
    retention_policy {
      max_retention_days    = var.snapshot_settings.retention_days
      on_source_disk_delete = "APPLY_RETENTION_POLICY"
    }
    snapshot_properties {
      storage_locations = [var.snapshot_settings.location]
      guest_flush       = false
      labels = merge(var.snapshot_settings.labels, local.labels, {
        backup_policy = "${local.prefix}-daily"
      })
    }
  }
}
