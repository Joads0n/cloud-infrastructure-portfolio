variable "platform_settings" {
  description = "Bootstrap project and regional settings used by the migration lab."
  type = object({
    bootstrap_project_id = string
    region               = string
    zone                 = string
    labels               = map(string)
  })
}

variable "project_settings" {
  description = "Destination GCP project settings. The project is created when create_project is true."
  type = object({
    project_id         = string
    project_name       = optional(string, "Maple Harbor VM migration lab")
    billing_account_id = optional(string, "")
    folder_id          = optional(string, "")
    create_project     = optional(bool, true)
  })

  validation {
    condition = !var.project_settings.create_project || (
      var.project_settings.billing_account_id != "" &&
      can(regex("^[0-9A-Fa-f-]{6,}$", var.project_settings.billing_account_id))
    )
    error_message = "A billing account ID is required when create_project is true."
  }
}

variable "network_settings" {
  description = "Destination network settings for the migrated VMs and global load balancer."
  type = object({
    vpc_name      = optional(string, "maple-m2vm-target-vpc")
    subnet_name   = optional(string, "maple-m2vm-target-subnet")
    subnet_cidr   = string
    router_name   = optional(string, "maple-m2vm-router")
    nat_name      = optional(string, "maple-m2vm-nat")
    dns_zone_name = optional(string, "maple-migration-zone")
    dns_name      = optional(string, "migration.maple.example.")
    record_name   = optional(string, "orders.migration.maple.example.")
  })

  validation {
    condition     = can(cidrhost(var.network_settings.subnet_cidr, 0))
    error_message = "subnet_cidr must be a valid IPv4 CIDR."
  }

  validation {
    condition     = endswith(var.network_settings.dns_name, ".") && endswith(var.network_settings.record_name, ".")
    error_message = "dns_name and record_name must be fully qualified DNS names ending with a dot."
  }
}

variable "m2vm_settings" {
  description = "Fictional AWS source contract and post-migration VM backend settings."
  type = object({
    source_name                = optional(string, "maple-aws-source")
    aws_organization           = optional(string, "Maple Harbor Retail AWS organization")
    aws_account_alias          = optional(string, "maple-harbor-migration")
    aws_region                 = optional(string, "us-east-1")
    source_vm_tag_key          = optional(string, "migrate-to-gcp")
    source_vm_tag_value        = optional(string, "true")
    source_security_group_ids  = optional(list(string), ["sg-fictional-m2vm-source"])
    target_instance_self_links = optional(list(string), [])
  })

  validation {
    condition     = length(var.m2vm_settings.target_instance_self_links) == 0 || length(var.m2vm_settings.target_instance_self_links) == 2
    error_message = "Provide either no target instance self-links before migration or exactly two after migration."
  }

  validation {
    condition     = length(var.m2vm_settings.source_security_group_ids) > 0
    error_message = "At least one fictional AWS security group filter is required."
  }
}

variable "cutover_settings" {
  description = "DNS cutover and rollback settings."
  type = object({
    active_backend      = optional(string, "aws")
    fictional_source_ip = optional(string, "198.51.100.20")
    ttl                 = optional(number, 30)
  })

  validation {
    condition     = contains(["aws", "gcp"], var.cutover_settings.active_backend)
    error_message = "active_backend must be either aws or gcp."
  }

  validation {
    condition     = var.cutover_settings.ttl >= 30 && var.cutover_settings.ttl <= 300
    error_message = "DNS TTL must be between 30 and 300 seconds for the exercise."
  }
}
