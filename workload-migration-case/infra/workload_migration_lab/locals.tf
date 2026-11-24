locals {
  destination_project_id = var.project_settings.project_id

  common_labels = merge(
    {
      case       = "workload-migration-case"
      company    = "maple-harbor-retail"
      managed_by = "terraform"
      migration  = "aws-to-gcp-vm"
    },
    var.platform_settings.labels,
  )

  migration_apis = toset([
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "servicecontrol.googleapis.com",
    "servicemanagement.googleapis.com",
    "serviceusage.googleapis.com",
    "vmmigration.googleapis.com",
  ])

  target_instance_self_links = var.m2vm_settings.target_instance_self_links
}
