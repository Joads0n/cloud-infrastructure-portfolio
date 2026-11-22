locals {
  common_labels = merge(
    {
      case       = "hybrid-cloud-networking"
      company    = "orion-field-services"
      managed_by = "terraform"
    },
    var.platform_settings.labels,
  )
}
