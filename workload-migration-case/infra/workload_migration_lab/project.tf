resource "google_project" "destination" {
  count = var.project_settings.create_project ? 1 : 0

  project_id          = var.project_settings.project_id
  name                = var.project_settings.project_name
  billing_account     = var.project_settings.billing_account_id
  org_id              = var.project_settings.organization_id
  folder_id           = var.project_settings.folder_id
  auto_create_network = false
  deletion_policy     = "DELETE"
  labels              = local.project_labels
}

resource "google_project_service" "migration" {
  for_each                   = local.migration_apis
  project                    = local.destination_project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false

  depends_on = [google_project.destination]
}
