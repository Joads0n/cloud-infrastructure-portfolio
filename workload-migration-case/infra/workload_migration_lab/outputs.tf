output "destination_project_id" {
  description = "Projeto GCP usado como host do M2VM e destino da carga."
  value       = local.destination_project_id
}

output "region" {
  description = "Região GCP usada pelo destino."
  value       = local.region
}

output "zone" {
  description = "Zona GCP usada pelo grupo não gerenciado."
  value       = local.zone
}

output "network_name" {
  description = "Nome da VPC de destino."
  value       = local.network_name
}

output "subnet_name" {
  description = "Nome da subnet de destino."
  value       = local.subnet_name
}

output "router_name" {
  description = "Nome do Cloud Router de destino."
  value       = local.router_name
}

output "nat_name" {
  description = "Nome do Cloud NAT de destino."
  value       = local.nat_name
}

output "instance_group_name" {
  description = "Grupo não gerenciado que recebe as VMs criadas pelo M2VM."
  value       = google_compute_instance_group.target.name
}

output "backend_service_name" {
  description = "Backend service global do Application Load Balancer."
  value       = google_compute_backend_service.target.name
}

output "health_check_name" {
  description = "Health check HTTP dos backends migrados."
  value       = google_compute_health_check.target.name
}

output "dns_zone_name" {
  description = "Zona DNS usada pelo cutover."
  value       = google_dns_managed_zone.migration.name
}

output "target_instance_self_links" {
  description = "Self-links das VMs migradas informados ao backend."
  value       = local.target_instance_self_links
}

output "active_backend_ip" {
  description = "Endereço atualmente selecionado pelo registro DNS."
  value       = var.cutover_settings.active_backend == "gcp" ? google_compute_global_address.target.address : var.cutover_settings.fictional_source_ip
}

output "m2vm_source_contract" {
  description = "Contrato não sensível de configuração da origem AWS no M2VM."
  value       = terraform_data.m2vm_aws_source_contract.output
}

output "global_load_balancer_ip" {
  description = "Endereço IPv4 do Application Load Balancer global externo."
  value       = google_compute_global_address.target.address
}

output "global_load_balancer_name" {
  description = "Nome do endereço IPv4 global do Application Load Balancer."
  value       = google_compute_global_address.target.name
}

output "health_firewall_name" {
  description = "Regra de firewall para os health checks do Load Balancer."
  value       = google_compute_firewall.lb_health_check.name
}

output "iap_firewall_name" {
  description = "Regra de firewall para SSH via IAP."
  value       = google_compute_firewall.iap_ssh.name
}

output "active_backend" {
  description = "Backend selecionado pela entrada de cutover do DNS."
  value       = var.cutover_settings.active_backend
}

output "cutover_record" {
  description = "FQDN usado pelo exercício de cutover."
  value       = google_dns_record_set.active_backend.name
}
