locals {
  common_labels = merge(
    {
      case       = "secure-network-architecture"
      company    = "vertice-comercio-digital"
      managed_by = "terraform"
    },
    var.platform_settings.labels,
    var.project_settings.labels,
  )

  lab_folder_id = var.organization_settings.folder_id != "" ? var.organization_settings.folder_id : (
    var.organization_settings.create_folder ? google_folder.lab[0].name : null
  )

  apps_project_id     = var.project_settings.apps_project_id
  services_project_id = var.project_settings.services_project_id

  network_cidrs = [
    var.network_settings.apps_application_cidr,
    var.network_settings.apps_test_cidr,
    var.network_settings.services_cidr,
  ]

  network_cidr_start_numbers = [
    for cidr in local.network_cidrs : sum([
      for index, octet in split(".", cidrhost(cidr, 0)) : parseint(octet, 10) * pow(256, 3 - index)
    ])
  ]

  network_cidr_end_numbers = [
    for cidr in local.network_cidrs : sum([
      for index, octet in split(".", cidrhost(cidr, -1)) : parseint(octet, 10) * pow(256, 3 - index)
    ])
  ]

  api_services = toset([
    "privateca.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "iap.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "networkmanagement.googleapis.com",
    "networksecurity.googleapis.com",
    "oslogin.googleapis.com",
    "serviceusage.googleapis.com",
  ])
}
