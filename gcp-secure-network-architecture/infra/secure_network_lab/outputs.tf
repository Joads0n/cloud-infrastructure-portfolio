output "apps_project_id" {
  description = "ID do projeto de aplicações."
  value       = local.apps_project_id
}

output "services_project_id" {
  description = "ID do projeto de serviços internos."
  value       = local.services_project_id
}

output "apps_vpc_self_link" {
  description = "Self-link da VPC de aplicações."
  value       = google_compute_network.apps.self_link
}

output "services_vpc_self_link" {
  description = "Self-link da VPC de serviços internos."
  value       = google_compute_network.services.self_link
}

output "orders_private_ip" {
  description = "IP privado do serviço de pedidos e estoque."
  value       = google_compute_instance.orders.network_interface[0].network_ip
}

output "ngfw_endpoint_id" {
  description = "Endpoint do Cloud NGFW Enterprise."
  value       = google_network_security_firewall_endpoint.services.id
}

output "private_service_hostname" {
  description = "Nome DNS privado do serviço interno."
  value       = var.network_settings.service_record_name
}
