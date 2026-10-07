resource "google_compute_region_instance_group_manager" "nginx" {
  name                      = local.vm_name
  region                    = local.region
  base_instance_name        = local.vm_name
  distribution_policy_zones = local.zones
  target_size               = var.compute_settings.backend_count
  version {
    instance_template = google_compute_instance_template.nginx.id
  }
  named_port {
    name = "http"
    port = 80
  }
  update_policy {
    type                         = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 0
    max_unavailable_fixed        = length(local.zones)
    replacement_method           = "RECREATE"
    instance_redistribution_type = "PROACTIVE"
  }
  # Sem recuperação automática da aplicação: separa o comportamento de saúde do LB da recriação de VMs.
  depends_on = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry, google_compute_router_nat.packages, google_compute_firewall.web_egress, google_compute_firewall.deny_egress]
}
