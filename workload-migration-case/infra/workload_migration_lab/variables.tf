variable "platform_settings" {
  description = "Existing project and regional settings for the migration lab."
  type = object({
    project_id = string
    region     = string
    zone       = string
    labels     = map(string)
  })
}

variable "network_settings" {
  description = "Separate source and target network ranges."
  type = object({
    source_vpc_name    = optional(string, "maple-legacy-source-vpc")
    target_vpc_name    = optional(string, "maple-migration-target-vpc")
    source_subnet_cidr = string
    target_subnet_cidr = string
    source_subnet_name = optional(string, "maple-legacy-source")
    target_subnet_name = optional(string, "maple-migration-target")
    dns_zone_name      = optional(string, "internal.maple.example.")
    dns_record_name    = optional(string, "orders.internal.maple.example.")
  })

  validation {
    condition = alltrue([
      for cidr in [
        var.network_settings.source_subnet_cidr,
        var.network_settings.target_subnet_cidr
      ] : can(cidrhost(cidr, 0))
    ])
    error_message = "Source and target subnet ranges must be valid IPv4 CIDRs."
  }
}

variable "migration_settings" {
  description = "Cutover selection and target sizing."
  type = object({
    active_backend          = optional(string, "source")
    target_size             = optional(number, 2)
    artifact_bucket_name    = string
    artifact_retention_days = optional(number, 7)
  })

  validation {
    condition     = contains(["source", "target"], var.migration_settings.active_backend)
    error_message = "active_backend must be either source or target."
  }

  validation {
    condition     = var.migration_settings.target_size >= 1
    error_message = "The target MIG must have at least one instance."
  }
}
