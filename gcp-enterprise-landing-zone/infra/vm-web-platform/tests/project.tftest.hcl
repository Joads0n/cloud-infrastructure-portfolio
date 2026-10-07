mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_settings = {
    project_id         = "fictional-crl-evaluator"
    billing_account_id = "000000-000000-000000"
  }

  compute_settings = {
    image = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
  }

  load_balancer_settings = {
    allow_public_http = true
  }
}

run "create_disposable_project" {
  command = plan
  assert {
    condition     = length(google_project.production) == 1 && google_project.production[0].deletion_policy == "DELETE" && !google_project.production[0].auto_create_network
    error_message = "Crie um projeto descartável sem rede padrão."
  }
  assert {
    condition     = google_project.production[0].billing_account == var.project_settings.billing_account_id && google_project.production[0].labels["environment"] == "prod" && google_project.production[0].labels["managed_by"] == "terraform"
    error_message = "O projeto criado deve receber vínculo de faturamento e labels."
  }
  assert {
    condition     = length(google_project_service.required) == 6 && !contains(keys(google_project_service.required), "storage.googleapis.com") && google_project_service.monitoring.service == "monitoring.googleapis.com"
    error_message = "Habilite as APIs necessárias à implantação no projeto criado."
  }
}

run "use_existing_project_without_adopting_it" {
  command = plan
  variables {
    project_settings = {
      project_id         = "fictional-crl-evaluator"
      billing_account_id = null
      create_project     = false
    }
  }
  assert {
    condition     = length(google_project.production) == 0 && length(google_project_service.required) == 0 && output.project_id == var.project_settings.project_id
    error_message = "Projetos existentes e suas APIs básicas gerenciadas pelo seed não devem ser assumidos."
  }
}

run "reject_missing_billing" {
  command = plan
  variables {
    project_settings = {
      project_id         = "fictional-crl-evaluator"
      billing_account_id = null
    }
  }
  expect_failures = [var.project_settings]
}

run "reject_existing_project_billing_management" {
  command = plan
  variables {
    project_settings = {
      project_id         = "fictional-crl-evaluator"
      billing_account_id = "000000-000000-000000"
      create_project     = false
    }
  }
  expect_failures = [var.project_settings]
}

run "reject_two_parents" {
  command = plan
  variables {
    project_settings = {
      project_id         = "fictional-crl-evaluator"
      billing_account_id = "000000-000000-000000"
      organization_id    = "123456789012"
      folder_id          = "234567890123"
    }
  }
  expect_failures = [var.project_settings]
}
