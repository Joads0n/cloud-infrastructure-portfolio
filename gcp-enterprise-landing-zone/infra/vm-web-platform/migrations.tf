# Mapeamentos de endereços da configuração de produção imediatamente anterior, baseada em módulo.
# Eles não movem arquivos de estado nem autorizam assumir estados antigos de dev/seed.

moved {
  from = module.nginx.google_compute_firewall.health
  to   = google_compute_firewall.health
}

moved {
  from = module.nginx.google_compute_firewall.iap
  to   = google_compute_firewall.iap
}

moved {
  from = module.nginx.google_compute_firewall.deny_ingress
  to   = google_compute_firewall.deny_ingress
}

moved {
  from = module.nginx.google_compute_firewall.web_egress
  to   = google_compute_firewall.web_egress
}

moved {
  from = module.nginx.google_compute_firewall.deny_egress
  to   = google_compute_firewall.deny_egress
}

moved {
  from = module.nginx.google_compute_health_check.app
  to   = google_compute_health_check.app
}

moved {
  from = module.nginx.google_compute_backend_service.app
  to   = google_compute_backend_service.app
}

moved {
  from = module.nginx.google_compute_url_map.app
  to   = google_compute_url_map.app
}

moved {
  from = module.nginx.google_compute_target_http_proxy.app
  to   = google_compute_target_http_proxy.app
}

moved {
  from = module.nginx.google_compute_global_address.app
  to   = google_compute_global_address.app
}

moved {
  from = module.nginx.google_compute_global_forwarding_rule.app
  to   = google_compute_global_forwarding_rule.app
}

moved {
  from = module.nginx.google_compute_target_https_proxy.app
  to   = google_compute_target_https_proxy.app
}

moved {
  from = module.nginx.google_compute_global_forwarding_rule.https
  to   = google_compute_global_forwarding_rule.https
}

moved {
  from = module.nginx.google_compute_region_instance_group_manager.nginx
  to   = google_compute_region_instance_group_manager.nginx
}

moved {
  from = module.nginx.google_compute_router.egress
  to   = google_compute_router.egress
}

moved {
  from = module.nginx.google_compute_address.nat
  to   = google_compute_address.nat
}

moved {
  from = module.nginx.google_compute_router_nat.packages
  to   = google_compute_router_nat.packages
}

moved {
  from = module.nginx.google_compute_network.workload
  to   = google_compute_network.workload
}

moved {
  from = module.nginx.google_compute_subnetwork.workload
  to   = google_compute_subnetwork.workload
}

moved {
  from = module.nginx.google_compute_resource_policy.daily_snapshot
  to   = google_compute_resource_policy.daily_snapshot
}

moved {
  from = module.nginx.google_compute_instance_template.nginx
  to   = google_compute_instance_template.nginx
}
