variable "platform_settings" {
  description = "Existing GCP project and regional settings for the lab."
  type = object({
    project_id = string
    region     = string
    zone       = string
    labels     = map(string)
  })
}

variable "network_settings" {
  description = "Cloud and simulated peer address ranges."
  type = object({
    cloud_vpc_name       = optional(string, "orion-cloud-vpc")
    peer_vpc_name        = optional(string, "orion-peer-fixture-vpc")
    cloud_subnet_cidr    = string
    peer_subnet_cidr     = string
    peer_advertised_cidr = string
  })

  validation {
    condition = alltrue([
      for cidr in [
        var.network_settings.cloud_subnet_cidr,
        var.network_settings.peer_subnet_cidr,
        var.network_settings.peer_advertised_cidr
      ] : can(cidrhost(cidr, 0))
    ])
    error_message = "All hybrid network ranges must be valid IPv4 CIDRs."
  }
}

variable "vpn_settings" {
  description = "HA VPN, external peer, and BGP parameters."
  sensitive   = true
  type = object({
    cloud_asn             = optional(number, 64514)
    peer_asn              = optional(number, 64520)
    peer_external_gateway = optional(string, "orion-simulated-peer")
    peer_ip_0             = string
    peer_ip_1             = string
    shared_secret         = string
    cloud_bgp_ip_0        = optional(string, "169.254.100.1")
    peer_bgp_ip_0         = optional(string, "169.254.100.2")
    cloud_bgp_ip_1        = optional(string, "169.254.101.1")
    peer_bgp_ip_1         = optional(string, "169.254.101.2")
  })

  validation {
    condition     = var.vpn_settings.cloud_asn != var.vpn_settings.peer_asn
    error_message = "Cloud and peer BGP ASNs must be different."
  }
}

variable "compute_settings" {
  description = "Optional private HTTP fixture."
  type = object({
    enabled      = optional(bool, true)
    name         = optional(string, "orion-cloud-service")
    machine_type = optional(string, "e2-micro")
    image        = optional(string, "projects/debian-cloud/global/images/family/debian-12")
  })
}
