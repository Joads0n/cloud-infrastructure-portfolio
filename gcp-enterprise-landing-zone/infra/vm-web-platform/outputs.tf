output "endpoint" {
  value     = var.load_balancer_settings.enable_https ? "https://${var.application_settings.hostname}" : "http://${google_compute_global_address.app.address}"
  sensitive = true
}

output "lb_ip" {
  description = "IPv4 público reservado, exibido ao final do apply. Remova-o das evidências publicadas."
  value       = google_compute_global_address.app.address
}

output "instance_group_manager" {
  value = google_compute_region_instance_group_manager.nginx.name
}

output "snapshot_schedule" {
  description = "Política regional herdada pelo disco de inicialização de cada VM, inclusive réplicas adicionadas no scaling."
  value       = google_compute_resource_policy.daily_snapshot.name
}

output "project_id" {
  description = "ID do projeto de destino. Mantenha-o privado; não publique outputs brutos."
  value       = local.project_id
  sensitive   = true
}
