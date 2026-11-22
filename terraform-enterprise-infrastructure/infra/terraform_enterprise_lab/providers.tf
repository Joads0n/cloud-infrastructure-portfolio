provider "google" {
  project               = var.platform_settings.project_id
  region                = var.platform_settings.region
  user_project_override = true
}
