resource "google_project_service" "apps" {
  for_each                   = local.api_services
  provider                   = google.apps
  project                    = local.apps_project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
  depends_on                 = [google_project.apps]
}

resource "google_project_service" "services" {
  for_each                   = local.api_services
  provider                   = google.services
  project                    = local.services_project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
  depends_on                 = [google_project.services]
}
