variable "project_settings" {
  description = "Projeto GCP criado manualmente pelo avaliador."
  type = object({
    project_id = string
  })
  nullable = false

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_settings.project_id))
    error_message = "Informe um ID de projeto GCP válido."
  }
}

variable "deployment_settings" {
  description = "Região, zona, prefixo e ambiente da implantação."
  type = object({
    environment     = optional(string, "lab")
    resource_prefix = optional(string, "mhr-m2vm-lab")
    region          = optional(string, "us-central1")
    zone            = optional(string, "us-central1-a")
  })
  default  = {}
  nullable = false

  validation {
    condition     = can(regex("^(lab|dev|test|prod)$", var.deployment_settings.environment))
    error_message = "Use um ambiente entre lab, dev, test ou prod."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,18}[a-z0-9]$", var.deployment_settings.resource_prefix))
    error_message = "Use um prefixo de 2 a 20 caracteres minúsculos, começando com letra e terminando com letra ou dígito."
  }

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+$", var.deployment_settings.region))
    error_message = "Informe uma região GCP válida."
  }

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+-[a-z]$", var.deployment_settings.zone)) && startswith(var.deployment_settings.zone, "${var.deployment_settings.region}-")
    error_message = "Informe uma zona GCP válida dentro da região definida."
  }
}

variable "network_settings" {
  description = "Configurações da rede de destino para as VMs migradas e o balanceador global."
  type = object({
    vpc_name      = optional(string)
    subnet_name   = optional(string)
    subnet_cidr   = string
    router_name   = optional(string)
    nat_name      = optional(string)
    dns_zone_name = optional(string)
    dns_name      = optional(string)
    record_name   = optional(string)
  })

  validation {
    condition     = can(cidrhost(var.network_settings.subnet_cidr, 0))
    error_message = "subnet_cidr deve ser um CIDR IPv4 válido."
  }

  validation {
    condition     = endswith(coalesce(var.network_settings.dns_name, ""), ".") && endswith(coalesce(var.network_settings.record_name, ""), ".")
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
