locals {
  prefix   = var.deployment_settings.resource_prefix
  region   = var.deployment_settings.region
  subnet   = var.network_settings.subnet_cidr
  zones    = var.compute_settings.zones
  hostname = var.application_settings.hostname
  vm_name  = coalesce(var.compute_settings.vm_base_name, "${local.prefix}-nginx")
  lb_name  = coalesce(var.load_balancer_settings.lb_name, "${local.prefix}-http")
  # Labels automáticas de gerenciamento; não há herança de labels configuráveis.
  labels = {
    environment = var.deployment_settings.environment
    managed_by  = "terraform"
  }
  project_labels = merge(var.project_settings.labels, {
    environment = var.deployment_settings.environment
    managed_by  = "terraform"
  })
  vm_labels = merge(var.compute_settings.labels, {
    environment = var.deployment_settings.environment
    managed_by  = "terraform"
  })
}
