resource "google_network_security_security_profile" "threat_prevention" {
  provider    = google-beta.services
  parent      = "projects/${local.services_project_id}"
  name        = var.ngfw_settings.profile_name
  location    = "global"
  type        = "THREAT_PREVENTION"
  description = "Perfil Enterprise para detecção e prevenção de ameaças no laboratório."
  depends_on  = [google_project_service.services]
}

resource "google_network_security_security_profile_group" "threat_prevention" {
  provider                  = google-beta.services
  parent                    = "projects/${local.services_project_id}"
  name                      = var.ngfw_settings.profile_group_name
  location                  = "global"
  description               = "Grupo de perfil usado pelas regras de inspeção do laboratório."
  threat_prevention_profile = google_network_security_security_profile.threat_prevention.id
}

resource "google_network_security_firewall_endpoint" "services" {
  provider           = google-beta.services
  parent             = "projects/${local.services_project_id}"
  name               = var.ngfw_settings.endpoint_name
  location           = var.ngfw_settings.endpoint_zone
  billing_project_id = local.services_project_id
  depends_on         = [google_project_service.services]
}

resource "google_network_security_firewall_endpoint_association" "services" {
  provider          = google-beta.services
  parent            = "projects/${local.services_project_id}"
  name              = "services-ngfw-association"
  location          = var.ngfw_settings.endpoint_zone
  network           = google_compute_network.services.id
  firewall_endpoint = google_network_security_firewall_endpoint.services.id
  disabled          = false
}
