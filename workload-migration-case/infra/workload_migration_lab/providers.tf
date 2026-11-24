provider "google" {
  project               = var.project_settings.project_id
  region                = var.deployment_settings.region
  user_project_override = true
}

provider "google" {
  alias                 = "bootstrap"
  project               = var.platform_settings.bootstrap_project_id
  region                = var.deployment_settings.region
  user_project_override = true
}
