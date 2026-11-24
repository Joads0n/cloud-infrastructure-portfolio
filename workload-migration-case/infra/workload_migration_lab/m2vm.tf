# The Google Terraform provider exposes the vmmigration API service, but not
# first-class resources for AWS Source or MigratingVM objects. This resource
# keeps the non-secret M2VM source contract visible in Terraform state without
# pretending that a fictional AWS account was registered or contacted.
resource "terraform_data" "m2vm_aws_source_contract" {
  input = {
    host_project_id        = local.destination_project_id
    gcp_region             = var.platform_settings.region
    source_name            = var.m2vm_settings.source_name
    aws_organization       = var.m2vm_settings.aws_organization
    aws_account_alias      = var.m2vm_settings.aws_account_alias
    aws_region             = var.m2vm_settings.aws_region
    source_vm_tag_key      = var.m2vm_settings.source_vm_tag_key
    source_vm_tag_value    = var.m2vm_settings.source_vm_tag_value
    security_group_filters = join(",", var.m2vm_settings.source_security_group_ids)
  }

  depends_on = [google_project_service.migration]
}
