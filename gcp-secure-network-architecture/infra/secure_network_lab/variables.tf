variable "platform_settings" {
  description = "Projeto usado para operações administrativas, faturamento e localização padrão."
  type = object({
    bootstrap_project_id = string
    billing_project_id   = string
    region               = string
    zones                = list(string)
    labels               = map(string)
  })

  validation {
    condition     = length(var.platform_settings.zones) >= 2
    error_message = "Informe pelo menos duas zonas para o laboratório."
  }
}

variable "organization_settings" {
  description = "Hierarquia opcional para a pasta dedicada do laboratório."
  type = object({
    organization_id = optional(string, "")
    folder_id       = optional(string, "")
    create_folder   = optional(bool, true)
    folder_name     = optional(string, "vertice-network-lab")
  })

  validation {
    condition = var.organization_settings.create_folder ? (
      var.organization_settings.organization_id != "" && var.organization_settings.folder_id == ""
      ) : (
      var.organization_settings.folder_id != "" || var.organization_settings.organization_id == ""
    )
    error_message = "Use organization_id sem folder_id ao criar uma pasta; para reutilizar uma pasta informe folder_id com create_folder=false; para No organization deixe ambos vazios."
  }
}

variable "project_settings" {
  description = "Projetos que isolam aplicações e serviços internos."
  type = object({
    create_projects       = optional(bool, true)
    apps_project_id       = string
    services_project_id   = string
    apps_project_name     = optional(string, "Vertice Aplicacoes")
    services_project_name = optional(string, "Vertice Servicos Internos")
    billing_account_id    = optional(string, "")
    labels                = optional(map(string), {})
  })

  validation {
    condition     = var.project_settings.apps_project_id != var.project_settings.services_project_id
    error_message = "Os projetos de aplicações e serviços devem ser diferentes."
  }

  validation {
    condition = var.project_settings.create_projects ? (
      var.project_settings.billing_account_id != ""
      ) : (
      var.project_settings.billing_account_id == ""
    )
    error_message = "Ao criar projetos, informe billing_account_id; no modo existente, deixe-o vazio."
  }
}

variable "network_settings" {
  description = "VPCs, sub-redes, CIDRs e DNS privado do cenário."
  type = object({
    apps_vpc_name         = optional(string, "vertice-apps-vpc")
    services_vpc_name     = optional(string, "vertice-services-vpc")
    apps_application_cidr = string
    apps_test_cidr        = string
    services_cidr         = string
    dns_zone_name         = optional(string, "internal.vertice.example.")
    service_record_name   = optional(string, "orders.internal.vertice.example.")
  })

  validation {
    condition = alltrue([
      for cidr in [
        var.network_settings.apps_application_cidr,
        var.network_settings.apps_test_cidr,
        var.network_settings.services_cidr
      ] : can(cidrhost(cidr, 0))
    ])
    error_message = "Todos os CIDRs devem ser redes IPv4 válidas."
  }

  validation {
    condition = (
      var.network_settings.service_record_name != var.network_settings.dns_zone_name &&
      endswith(var.network_settings.service_record_name, var.network_settings.dns_zone_name)
    )
    error_message = "service_record_name deve ser um nome abaixo de dns_zone_name e ambos devem usar o ponto final."
  }
}

variable "compute_settings" {
  description = "VMs pequenas e imagem do sistema operacional."
  type = object({
    machine_type      = optional(string, "f1-micro")
    image             = optional(string, "projects/debian-cloud/global/images/family/debian-12")
    application_name  = optional(string, "vertice-app")
    test_name         = optional(string, "vertice-test")
    service_name      = optional(string, "vertice-orders")
    boot_disk_size_gb = optional(number, 10)
  })
}

variable "ngfw_settings" {
  description = "Cloud NGFW Enterprise e inspeção de ameaças."
  type = object({
    enabled            = optional(bool, true)
    endpoint_name      = optional(string, "vertice-ngfw-endpoint")
    endpoint_zone      = optional(string, "us-central1-a")
    profile_name       = optional(string, "vertice-threat-prevention")
    profile_group_name = optional(string, "vertice-threat-prevention-group")
    enable_logging     = optional(bool, true)
  })

  validation {
    condition     = var.ngfw_settings.enabled
    error_message = "Cloud NGFW Enterprise com IDS/IPS é requisito obrigatório deste case."
  }
}

variable "test_settings" {
  description = "Parâmetros dos Connectivity Tests declarativos."
  type = object({
    enabled = optional(bool, true)
    port    = optional(number, 80)
  })
}
