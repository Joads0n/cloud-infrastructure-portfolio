provider "google" {
  project               = var.platform_settings.bootstrap_project_id
  region                = var.platform_settings.region
  billing_project       = var.platform_settings.billing_project_id
  user_project_override = true
}

provider "google-beta" {
  project               = var.platform_settings.bootstrap_project_id
  region                = var.platform_settings.region
  billing_project       = var.platform_settings.billing_project_id
  user_project_override = true
}

provider "google" {
  alias                 = "apps"
  project               = var.project_settings.apps_project_id
  region                = var.platform_settings.region
  billing_project       = var.platform_settings.billing_project_id
  user_project_override = true
}

provider "google" {
  alias                 = "services"
  project               = var.project_settings.services_project_id
  region                = var.platform_settings.region
  billing_project       = var.platform_settings.billing_project_id
  user_project_override = true
}

provider "google-beta" {
  alias                 = "apps"
  project               = var.project_settings.apps_project_id
  region                = var.platform_settings.region
  billing_project       = var.platform_settings.billing_project_id
  user_project_override = true
}

provider "google-beta" {
  alias                 = "services"
  project               = var.project_settings.services_project_id
  region                = var.platform_settings.region
  billing_project       = var.platform_settings.billing_project_id
  user_project_override = true
}
