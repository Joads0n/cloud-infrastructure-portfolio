resource "google_project_service" "migration" {
  for_each                   = local.migration_apis
  project                    = var.project_settings.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}
