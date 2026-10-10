# Sem chaves; a conta de execução recebe somente os papéis de escrita de telemetria abaixo.
resource "google_service_account" "runtime" {
  depends_on   = [google_project_service.required]
  project      = local.project_id
  account_id   = var.identity_settings.runtime_service_account_id
  display_name = "${var.identity_settings.runtime_service_account_id} Nginx runtime"
}
