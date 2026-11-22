resource "google_folder" "lab" {
  count        = var.organization_settings.create_folder ? 1 : 0
  display_name = var.organization_settings.folder_name
  parent       = "organizations/${var.organization_settings.organization_id}"
}

resource "google_project" "apps" {
  count           = var.project_settings.create_projects ? 1 : 0
  project_id      = var.project_settings.apps_project_id
  name            = var.project_settings.apps_project_name
  billing_account = var.project_settings.billing_account_id
  folder_id       = local.lab_folder_id
  labels          = merge(local.common_labels, { role = "applications" })
  deletion_policy = "DELETE"
}

resource "google_project" "services" {
  count           = var.project_settings.create_projects ? 1 : 0
  project_id      = var.project_settings.services_project_id
  name            = var.project_settings.services_project_name
  billing_account = var.project_settings.billing_account_id
  folder_id       = local.lab_folder_id
  labels          = merge(local.common_labels, { role = "internal-services" })
  deletion_policy = "DELETE"
}
