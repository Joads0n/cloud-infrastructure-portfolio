locals {
  common_labels = merge(
    {
      case       = "workload-migration-case"
      company    = "maple-harbor-retail"
      managed_by = "terraform"
    },
    var.platform_settings.labels,
  )

  migration_apis = toset([
    "compute.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
  ])
}
