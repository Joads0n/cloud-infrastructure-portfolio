# O provider Terraform Google expõe a API vmmigration, mas não possui recursos
# nativos para objetos AWS Source ou MigratingVM. Este recurso mantém o contrato
# não sensível da origem M2VM visível no estado sem fingir que uma conta AWS
# fictícia foi registrada ou contatada.
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
