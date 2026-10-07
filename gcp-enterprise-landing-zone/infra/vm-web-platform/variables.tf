variable "project_settings" {
  description = "Projeto, faturamento, hierarquia e labels do projeto."
  type = object({
    project_id         = string
    create_project     = optional(bool, true)
    project_name       = optional(string, "Cedar Route Production")
    billing_account_id = optional(string)
    organization_id    = optional(string)
    folder_id          = optional(string)
    labels             = optional(map(string), {})
  })
  nullable = false

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_settings.project_id))
    error_message = "Informe um ID de projeto GCP válido."
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9 '!-]{4,30}$", var.project_settings.project_name))
    error_message = "Use um nome de exibição de projeto GCP com 4 a 30 caracteres."
  }

  validation {
    condition     = var.project_settings.create_project ? can(regex("^[A-Fa-f0-9]{6}-[A-Fa-f0-9]{6}-[A-Fa-f0-9]{6}$", var.project_settings.billing_account_id)) : var.project_settings.billing_account_id == null
    error_message = "A criação exige um ID de conta de faturamento (XXXXXX-XXXXXX-XXXXXX); o modo de projeto existente exige null."
  }

  validation {
    condition     = var.project_settings.organization_id == null ? true : var.project_settings.create_project && var.project_settings.folder_id == null && can(regex("^[0-9]+$", var.project_settings.organization_id))
    error_message = "Informe um ID numérico de organização somente para criação e sem pasta."
  }

  validation {
    condition     = var.project_settings.folder_id == null ? true : var.project_settings.create_project && can(regex("^[0-9]+$", var.project_settings.folder_id))
    error_message = "Informe um ID numérico de pasta somente para criação; organization_id deve ser omitido."
  }

  validation {
    condition     = alltrue([for labels in [var.project_settings.labels == null ? {} : var.project_settings.labels] : length(labels) <= 62 && alltrue([for key, value in labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", key)) && can(regex("^[a-z0-9_-]{0,63}$", value))]) && !contains(keys(labels), "environment") && !contains(keys(labels), "managed_by")])
    error_message = "Use até 62 labels válidas em project_settings.labels; environment e managed_by são reservadas."
  }
}

variable "deployment_settings" {
  description = "Região, prefixo e ambiente da implantação."
  type = object({
    environment     = optional(string, "prod")
    resource_prefix = optional(string, "crl-prod")
    region          = optional(string, "us-central1")
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.deployment_settings.environment == "prod"
    error_message = "Este case aceita somente o laboratório de produção."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,18}[a-z0-9]$", var.deployment_settings.resource_prefix))
    error_message = "Use um prefixo de 2 a 20 caracteres minúsculos, começando com letra e terminando com letra ou dígito."
  }

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]+$", var.deployment_settings.region))
    error_message = "Informe uma região GCP válida."
  }
}

variable "network_settings" {
  description = "Rede; regras de firewall e NAT permanecem definidas pela arquitetura."
  type = object({
    subnet_cidr = optional(string, "10.80.10.0/24")
    vpc_name    = optional(string)
    subnet_name = optional(string)
  })
  default  = {}
  nullable = false

  validation {
    condition = can(cidrnetmask(var.network_settings.subnet_cidr)) && try(
      tonumber(split("/", var.network_settings.subnet_cidr)[1]) <= 28 && (
        (startswith(var.network_settings.subnet_cidr, "10.") && tonumber(split("/", var.network_settings.subnet_cidr)[1]) >= 8) ||
        (can(regex("^172\\.(1[6-9]|2[0-9]|3[01])\\.", var.network_settings.subnet_cidr)) && tonumber(split("/", var.network_settings.subnet_cidr)[1]) >= 12) ||
        (startswith(var.network_settings.subnet_cidr, "192.168.") && tonumber(split("/", var.network_settings.subnet_cidr)[1]) >= 16)
    ), false)
    error_message = "Informe um CIDR de sub-rede IPv4 privada RFC1918, com bloco de tamanho igual ou maior que /28 e contido na faixa privada."
  }

  validation {
    condition     = alltrue([for name in [var.network_settings.vpc_name, var.network_settings.subnet_name] : name == null ? true : can(regex("^[a-z]([a-z0-9-]{0,28}[a-z0-9])?$", name))])
    error_message = "Nomes opcionais devem ter de 1 a 30 letras minúsculas, dígitos ou hífens, começar com letra e terminar com letra ou dígito; reserve espaço para os sufixos gerados."
  }
}

variable "compute_settings" {
  description = "VMs, discos, réplicas e labels das VMs."
  type = object({
    image             = string
    backend_count     = optional(number, 2)
    vm_base_name      = optional(string)
    machine_type      = optional(string, "e2-micro")
    boot_disk_type    = optional(string, "pd-standard")
    boot_disk_size_gb = optional(number, 10)
    enable_display    = optional(bool, true)
    labels            = optional(map(string), {})
    zones             = optional(list(string), ["us-central1-a", "us-central1-b"])
  })
  nullable = false

  validation {
    condition     = can(regex("^projects/debian-cloud/global/images/debian-12-", var.compute_settings.image))
    error_message = "Informe o caminho exato de uma imagem oficial Debian 12, não uma família de imagens."
  }

  validation {
    condition     = contains([2, 3], var.compute_settings.backend_count)
    error_message = "Use duas réplicas, ou três para o teste limitado de scaling manual."
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]+$", var.compute_settings.machine_type)) && contains(["pd-standard", "pd-balanced", "pd-ssd"], var.compute_settings.boot_disk_type) && var.compute_settings.boot_disk_size_gb >= 10 && floor(var.compute_settings.boot_disk_size_gb) == var.compute_settings.boot_disk_size_gb
    error_message = "Informe o tipo de máquina, um tipo de disco persistente aceito e um tamanho inteiro de disco de inicialização de pelo menos 10 GB. Verifique disponibilidade e custos separadamente."
  }

  validation {
    condition     = alltrue([for name in [var.compute_settings.vm_base_name] : name == null ? true : can(regex("^[a-z]([a-z0-9-]{0,28}[a-z0-9])?$", name))])
    error_message = "Nomes opcionais devem ter de 1 a 30 letras minúsculas, dígitos ou hífens, começar com letra e terminar com letra ou dígito; reserve espaço para os sufixos gerados."
  }

  validation {
    condition     = alltrue([for labels in [var.compute_settings.labels == null ? {} : var.compute_settings.labels] : length(labels) <= 62 && alltrue([for key, value in labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", key)) && can(regex("^[a-z0-9_-]{0,63}$", value))]) && !contains(keys(labels), "environment") && !contains(keys(labels), "managed_by")])
    error_message = "Use até 62 labels válidas em compute_settings.labels; environment e managed_by são reservadas."
  }

  validation {
    condition     = length(var.compute_settings.zones) == 2 && length(distinct(var.compute_settings.zones)) == 2 && alltrue([for zone in var.compute_settings.zones : can(regex("^[a-z]+-[a-z]+[0-9]+-[a-z]$", zone)) && startswith(zone, "${var.deployment_settings.region}-")])
    error_message = "Escolha exatamente duas zonas distintas em compute_settings.zones, dentro de deployment_settings.region."
  }
}

variable "application_settings" {
  description = "Aplicação de demonstração."
  type = object({
    hostname = optional(string, "app.cedar-route.example")
  })
  default  = {}
  nullable = false

  validation {
    condition     = length(var.application_settings.hostname) <= 253 && can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+$", var.application_settings.hostname))
    error_message = "Informe um nome de host DNS em minúsculas, sem espaços, metacaracteres de shell, esquema ou caminho."
  }
}

variable "load_balancer_settings" {
  description = "Exposição HTTP/HTTPS e balanceamento."
  type = object({
    allow_public_http       = optional(bool, false)
    lb_name                 = optional(string)
    backend_max_utilization = optional(number, 0.8)
    enable_http             = optional(bool, true)
    enable_https            = optional(bool, false)
    ssl_certificate_ids     = optional(list(string), [])
  })
  default  = {}
  nullable = false

  validation {
    condition     = var.load_balancer_settings.backend_max_utilization > 0 && var.load_balancer_settings.backend_max_utilization <= 1
    error_message = "A utilização do backend deve ser maior que 0 e menor ou igual a 1."
  }

  validation {
    condition     = var.load_balancer_settings.enable_http || var.load_balancer_settings.enable_https
    error_message = "Habilite pelo menos um frontend: HTTP ou HTTPS."
  }

  validation {
    condition     = var.load_balancer_settings.enable_https ? length(var.load_balancer_settings.ssl_certificate_ids) >= 1 && length(var.load_balancer_settings.ssl_certificate_ids) <= 15 && alltrue([for id in var.load_balancer_settings.ssl_certificate_ids : can(regex("^(https://www.googleapis.com/compute/v1/)?projects/[a-z][a-z0-9-]+/global/sslCertificates/[a-z][a-z0-9-]*$", id))]) : length(var.load_balancer_settings.ssl_certificate_ids) == 0
    error_message = "HTTPS exige de 1 a 15 IDs de certificados SSL globais existentes do Compute, não chaves privadas nem IDs do Certificate Manager. Deixe a lista vazia para HTTP exclusivo."
  }

  validation {
    condition     = alltrue([for name in [var.load_balancer_settings.lb_name] : name == null ? true : can(regex("^[a-z]([a-z0-9-]{0,28}[a-z0-9])?$", name))])
    error_message = "Nomes opcionais devem ter de 1 a 30 letras minúsculas, dígitos ou hífens, começar com letra e terminar com letra ou dígito; reserve espaço para os sufixos gerados."
  }
}

variable "snapshot_settings" {
  description = "Snapshots dos discos de inicialização."
  type = object({
    start_time     = optional(string, "05:00")
    retention_days = optional(number, 7)
    location       = optional(string, "us")
    labels         = optional(map(string), {})
  })
  default  = {}
  nullable = false

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):00$", var.snapshot_settings.start_time)) && var.snapshot_settings.retention_days >= 1 && floor(var.snapshot_settings.retention_days) == var.snapshot_settings.retention_days && can(regex("^[a-z][a-z0-9-]+$", var.snapshot_settings.location))
    error_message = "Use uma hora cheia UTC para início dos snapshots (HH:00), retenção inteira positiva em dias e um local de armazenamento. Verifique a compatibilidade do local separadamente."
  }

  validation {
    condition     = length(var.snapshot_settings.labels) <= 61 && alltrue([for key, value in var.snapshot_settings.labels : can(regex("^[a-z][a-z0-9_-]{0,62}$", key)) && can(regex("^[a-z0-9_-]{0,63}$", value))]) && alltrue([for key in ["environment", "managed_by", "backup_policy"] : !contains(keys(var.snapshot_settings.labels), key)])
    error_message = "Use até 61 labels válidas nos snapshots; environment, managed_by e backup_policy são reservadas."
  }
}

variable "identity_settings" {
  description = "Identidade de execução sem chaves."
  type = object({
    runtime_service_account_id = optional(string, "crl-runtime-prod")
  })
  default  = {}
  nullable = false

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.identity_settings.runtime_service_account_id))
    error_message = "Use um ID de conta de serviço de 6 a 30 caracteres."
  }
}
