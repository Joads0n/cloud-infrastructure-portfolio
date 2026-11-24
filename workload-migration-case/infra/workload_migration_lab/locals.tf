locals {
  prefix = var.deployment_settings.resource_prefix
  region = var.deployment_settings.region
  zone   = var.deployment_settings.zone

  destination_project_id = var.project_settings.project_id

  network_name  = coalesce(var.network_settings.vpc_name, "${local.prefix}-vpc")
  subnet_name   = coalesce(var.network_settings.subnet_name, "${local.prefix}-subnet")
  router_name   = coalesce(var.network_settings.router_name, "${local.prefix}-router")
  nat_name      = coalesce(var.network_settings.nat_name, "${local.prefix}-nat")
  dns_zone_name = coalesce(var.network_settings.dns_zone_name, "${local.prefix}-dns")
  dns_name      = coalesce(var.network_settings.dns_name, "${local.prefix}.example.")
  record_name   = coalesce(var.network_settings.record_name, "app.${local.prefix}.example.")

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
