# Habilita APIs básicas somente nos projetos criados aqui. Projetos de teste existentes
# mantêm o gerenciamento original de suas APIs, inclusive pelo seed histórico.
resource "google_project_service" "required" {
  for_each = var.project_settings.create_project ? toset([
    "compute.googleapis.com",
    "iam.googleapis.com",
    "logging.googleapis.com",
    "iap.googleapis.com",
    "oslogin.googleapis.com",
    "serviceusage.googleapis.com"
  ]) : toset([])
  project            = local.project_id
  service            = each.value
  disable_on_destroy = false
}

# Mantém o endereço anterior do recurso e o comportamento para projeto existente.
resource "google_project_service" "monitoring" {
  project            = local.project_id
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}
# As APIs permanecem habilitadas durante a destruição dos recursos. No modo de criação, o projeto
# é excluído por último; no modo de projeto existente, as APIs continuam habilitadas.
