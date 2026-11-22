locals {
  common_labels = merge(
    {
      case       = "terraform-enterprise-infrastructure"
      company    = "cedar-route-logistics"
      managed_by = "terraform"
    },
    var.platform_settings.labels,
  )

  platform_apis = toset([
    "compute.googleapis.com",
    "cloudkms.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "secretmanager.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "sqladmin.googleapis.com",
    "storage.googleapis.com",
  ])
}
