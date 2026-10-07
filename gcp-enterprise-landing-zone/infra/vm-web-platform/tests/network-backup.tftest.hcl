mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_settings = {
    project_id     = "fictional-crl-tests"
    create_project = false
  }

  deployment_settings = {
    environment = "prod"
  }

  compute_settings = {
    backend_count = 3
    image         = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
  }

  load_balancer_settings = {
    allow_public_http = true
  }
}

run "reserved_addresses_firewall_and_snapshots" {
  command = plan
  assert {
    condition     = google_compute_instance_template.nginx.enable_display && alltrue([for backend in google_compute_backend_service.app.backend : backend.max_utilization == 0.8])
    error_message = "Habilite o dispositivo de vídeo e defina a utilização-alvo do LB em 80%."
  }
  assert {
    condition     = google_compute_resource_policy.daily_snapshot.snapshot_schedule_policy[0].schedule[0].daily_schedule[0].start_time == "05:00" && toset(google_compute_resource_policy.daily_snapshot.snapshot_schedule_policy[0].snapshot_properties[0].storage_locations) == toset(["us"])
    error_message = "Os snapshots usam a localização multirregional US e a janela de início 02:00-03:00 em Fortaleza."
  }
  assert {
    condition     = google_compute_global_address.app.address_type == "EXTERNAL" && google_compute_global_address.app.ip_version == "IPV4" && google_compute_router_nat.packages.nat_ip_allocate_option == "MANUAL_ONLY"
    error_message = "Use endereços públicos reservados para LB e NAT."
  }
  assert {
    condition     = toset(google_compute_firewall.health.source_ranges) == toset(["35.191.0.0/16", "130.211.0.0/22"]) && toset(google_compute_firewall.iap.source_ranges) == toset(["35.235.240.0/20"]) && google_compute_firewall.deny_ingress.priority > google_compute_firewall.iap.priority
    error_message = "Mantenha a entrada dos backends restrita ao LB, às verificações de integridade e ao IAP."
  }
  assert {
    condition     = length(google_compute_instance_template.nginx.disk[0].resource_policies) == 1 && google_compute_region_instance_group_manager.nginx.target_size == 3
    error_message = "O template deve vincular a política de snapshots às réplicas adicionadas no scaling."
  }
  assert {
    condition     = google_compute_resource_policy.daily_snapshot.snapshot_schedule_policy[0].schedule[0].daily_schedule[0].days_in_cycle == 1 && google_compute_resource_policy.daily_snapshot.snapshot_schedule_policy[0].retention_policy[0].max_retention_days == 7 && google_compute_resource_policy.daily_snapshot.snapshot_schedule_policy[0].retention_policy[0].on_source_disk_delete == "APPLY_RETENTION_POLICY"
    error_message = "Use snapshots diários com retenção de sete dias, inclusive após a exclusão da origem."
  }
}
