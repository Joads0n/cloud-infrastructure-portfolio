# Esta configuração gerencia somente o ciclo de vida de projetos descartáveis criados por ela.
resource "google_project" "production" {
  count               = var.project_settings.create_project ? 1 : 0
  project_id          = var.project_settings.project_id
  name                = var.project_settings.project_name
  billing_account     = var.project_settings.billing_account_id
  org_id              = var.project_settings.organization_id
  folder_id           = var.project_settings.folder_id
  auto_create_network = false
  deletion_policy     = "DELETE"
  labels              = local.project_labels
}

locals {
  # Esta referência também estabelece a dependência de criar o projeto antes dos recursos.
  project_id = var.project_settings.create_project ? google_project.production[0].project_id : var.project_settings.project_id
}
