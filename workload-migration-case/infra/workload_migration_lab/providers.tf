provider "google" {
  project = var.project_settings.project_id
  region  = var.deployment_settings.region
  # O projeto de destino é criado por este root; use a quota project da
  # autenticação do avaliador até que o projeto de destino esteja disponível.
  user_project_override = false
}
