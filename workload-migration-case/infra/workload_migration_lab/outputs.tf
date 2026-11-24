output "destination_project_id" {
  description = "GCP project used as the M2VM host and workload destination."
  value       = local.destination_project_id
}

output "m2vm_source_contract" {
  description = "Non-secret M2VM AWS source configuration contract."
  value       = terraform_data.m2vm_aws_source_contract.output
}

output "global_load_balancer_ip" {
  description = "Global external Application Load Balancer IPv4 address."
  value       = google_compute_global_address.target.address
}

output "active_backend" {
  description = "Backend selected by the DNS cutover input."
  value       = var.cutover_settings.active_backend
}

output "cutover_record" {
  description = "FQDN used by the cutover exercise."
  value       = google_dns_record_set.active_backend.name
}
