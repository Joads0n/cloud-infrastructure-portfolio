resource "google_project_iam_member" "telemetry" {
  for_each = toset(["roles/logging.logWriter", "roles/monitoring.metricWriter"])
  project  = local.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.runtime.email}"
}
