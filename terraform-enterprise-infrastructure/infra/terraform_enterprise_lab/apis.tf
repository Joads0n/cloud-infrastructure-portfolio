resource "google_project_service" "platform" {
  for_each                   = local.platform_apis
  project                    = var.platform_settings.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}
