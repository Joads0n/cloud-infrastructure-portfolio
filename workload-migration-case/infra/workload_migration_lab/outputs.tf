output "destination_project_id" {
  description = "Projeto GCP usado como host do M2VM e destino da carga."
  value       = local.destination_project_id
}

output "m2vm_source_contract" {
  description = "Contrato não sensível de configuração da origem AWS no M2VM."
  value       = terraform_data.m2vm_aws_source_contract.output
}

output "global_load_balancer_ip" {
  description = "Endereço IPv4 do Application Load Balancer global externo."
  value       = google_compute_global_address.target.address
}

output "active_backend" {
  description = "Backend selecionado pela entrada de cutover do DNS."
  value       = var.cutover_settings.active_backend
}

output "cutover_record" {
  description = "FQDN usado pelo exercício de cutover."
  value       = google_dns_record_set.active_backend.name
}
