resource "google_service_account" "apps_runtime" {
  provider     = google.apps
  project      = local.apps_project_id
  account_id   = "vertice-app-runtime"
  display_name = "Runtime da aplicação Vértice"
  depends_on   = [google_project_service.apps]
}

resource "google_service_account" "services_runtime" {
  provider     = google.services
  project      = local.services_project_id
  account_id   = "vertice-orders-runtime"
  display_name = "Runtime do serviço de pedidos Vértice"
  depends_on   = [google_project_service.services]
}

resource "google_project_iam_member" "apps_logging" {
  provider = google.apps
  project  = local.apps_project_id
  role     = "roles/logging.logWriter"
  member   = "serviceAccount:${google_service_account.apps_runtime.email}"
}

resource "google_project_iam_member" "apps_monitoring" {
  provider = google.apps
  project  = local.apps_project_id
  role     = "roles/monitoring.metricWriter"
  member   = "serviceAccount:${google_service_account.apps_runtime.email}"
}

resource "google_project_iam_member" "services_logging" {
  provider = google.services
  project  = local.services_project_id
  role     = "roles/logging.logWriter"
  member   = "serviceAccount:${google_service_account.services_runtime.email}"
}

resource "google_project_iam_member" "services_monitoring" {
  provider = google.services
  project  = local.services_project_id
  role     = "roles/monitoring.metricWriter"
  member   = "serviceAccount:${google_service_account.services_runtime.email}"
}
