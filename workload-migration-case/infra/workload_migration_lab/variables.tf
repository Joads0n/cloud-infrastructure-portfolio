variable "platform_settings" {
  description = "Projeto de bootstrap e configurações regionais usadas pelo laboratório de migração."
  type = object({
    bootstrap_project_id = string
    region               = string
    zone                 = string
    labels               = map(string)
  })
}

variable "project_settings" {
  description = "Configurações do projeto GCP de destino. O projeto é criado quando create_project é true."
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
    error_message = "O ID da conta de faturamento é obrigatório quando create_project é true."
  }
}

variable "network_settings" {
  description = "Configurações da rede de destino para as VMs migradas e o balanceador global."
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
    error_message = "subnet_cidr deve ser um CIDR IPv4 válido."
  }

  validation {
    condition     = endswith(var.network_settings.dns_name, ".") && endswith(var.network_settings.record_name, ".")
    error_message = "dns_name e record_name devem ser nomes DNS completos terminados em ponto."
  }
}

variable "m2vm_settings" {
  description = "Contrato da origem AWS fictícia e configurações do backend das VMs após a migração."
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
    error_message = "Informe nenhum self-link antes da migração ou exatamente dois após a migração."
  }

  validation {
    condition     = length(var.m2vm_settings.source_security_group_ids) > 0
    error_message = "É necessário informar pelo menos um filtro de security group AWS fictício."
  }
}

variable "cutover_settings" {
  description = "Configurações de cutover e rollback do DNS."
  type = object({
    active_backend      = optional(string, "aws")
    fictional_source_ip = optional(string, "198.51.100.20")
    ttl                 = optional(number, 30)
  })

  validation {
    condition     = contains(["aws", "gcp"], var.cutover_settings.active_backend)
    error_message = "active_backend deve ser aws ou gcp."
  }

  validation {
    condition     = var.cutover_settings.ttl >= 30 && var.cutover_settings.ttl <= 300
    error_message = "O TTL do DNS deve estar entre 30 e 300 segundos para o exercício."
  }
}
