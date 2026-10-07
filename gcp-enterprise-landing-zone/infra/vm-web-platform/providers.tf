provider "google" {
  project = var.project_settings.project_id
  region  = var.deployment_settings.region
}

provider "google-beta" {
  project = var.project_settings.project_id
  region  = var.deployment_settings.region
}
