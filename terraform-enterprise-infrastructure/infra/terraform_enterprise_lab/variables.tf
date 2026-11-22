variable "platform_settings" {
  description = "Existing project and regional settings for the platform lab."
  type = object({
    project_id = string
    region     = string
    zone       = string
    labels     = map(string)
  })
}

variable "network_settings" {
  description = "Private control-plane and data subnet ranges."
  type = object({
    vpc_name               = optional(string, "cedar-tfe-platform-vpc")
    management_subnet_name = optional(string, "cedar-tfe-management")
    data_subnet_name       = optional(string, "cedar-tfe-data")
    management_subnet_cidr = string
    data_subnet_cidr       = string
    private_services_cidr  = string
  })

  validation {
    condition = alltrue([
      for cidr in [
        var.network_settings.management_subnet_cidr,
        var.network_settings.data_subnet_cidr,
        var.network_settings.private_services_cidr
      ] : can(cidrhost(cidr, 0))
    ])
    error_message = "All platform network ranges must be valid IPv4 CIDRs."
  }
}

variable "database_settings" {
  description = "Private Cloud SQL PostgreSQL settings."
  sensitive   = true
  type = object({
    name             = optional(string, "cedar-tfe-postgres")
    database_version = optional(string, "POSTGRES_15")
    tier             = optional(string, "db-f1-micro")
    database_name    = optional(string, "terraform_enterprise")
    user_name        = optional(string, "tfe_runtime")
    password         = string
  })
}

variable "artifacts_settings" {
  description = "CMEK-backed artifact bucket settings."
  type = object({
    bucket_name    = string
    key_ring_name  = optional(string, "cedar-tfe-key-ring")
    key_name       = optional(string, "cedar-tfe-artifacts")
    retention_days = optional(number, 7)
  })
}
