mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_settings = {
    project_id         = "fictional-crl-labels"
    billing_account_id = "000000-000000-000000"
  }

  compute_settings = {
    image = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
  }

  load_balancer_settings = {
    allow_public_http = true
  }
}

run "omitted_labels_are_only_automatic" {
  command = plan
  assert {
    condition     = google_project.production[0].labels == tomap(local.labels) && google_compute_instance_template.nginx.labels == tomap(local.labels)
    error_message = "Sem labels informadas, projeto e VMs recebem somente as duas labels automáticas."
  }
}

run "independent_labels" {
  command = plan
  variables {
    project_settings = {
      project_id         = "fictional-crl-labels"
      billing_account_id = "000000-000000-000000"
      labels             = { owner = "platform", scope = "foundation" }
    }

    snapshot_settings = {
      labels = { owner = "backup" }
    }

    compute_settings = {
      image  = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
      labels = { owner = "operations", application = "nginx" }
    }
  }
  assert {
    condition     = google_project.production[0].labels == tomap({ owner = "platform", scope = "foundation", environment = "prod", managed_by = "terraform" }) && google_compute_instance_template.nginx.labels == tomap({ owner = "operations", application = "nginx", environment = "prod", managed_by = "terraform" }) && google_compute_resource_policy.daily_snapshot.snapshot_schedule_policy[0].snapshot_properties[0].labels == tomap({ owner = "backup", environment = "prod", managed_by = "terraform", backup_policy = "crl-prod-daily" })
    error_message = "Labels de projeto, VMs e snapshots são independentes."
  }
}

run "identical_explicit_labels" {
  command = plan
  variables {
    project_settings = {
      project_id         = "fictional-crl-labels"
      billing_account_id = "000000-000000-000000"
      labels             = { owner = "shared" }
    }

    compute_settings = {
      image  = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
      labels = { owner = "shared" }
    }
  }
  assert {
    condition     = google_project.production[0].labels == google_compute_instance_template.nginx.labels && google_project.production[0].labels["owner"] == "shared"
    error_message = "Mapas específicos iguais devem gerar labels iguais."
  }
}

run "empty_specific_maps" {
  command = plan
  variables {
    project_settings = {
      project_id         = "fictional-crl-labels"
      billing_account_id = "000000-000000-000000"
      labels             = {}
    }

    compute_settings = {
      image  = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
      labels = {}
    }
  }
  assert {
    condition     = google_project.production[0].labels == tomap({ environment = "prod", managed_by = "terraform" }) && google_compute_instance_template.nginx.labels == google_project.production[0].labels
    error_message = "Mapas específicos vazios devem manter somente as duas labels reservadas."
  }
}

run "reject_reserved_project_labels" {
  command = plan
  variables {
    project_settings = {
      project_id         = "fictional-crl-labels"
      billing_account_id = "000000-000000-000000"
      labels             = { managed_by = "manual" }
    }
  }
  expect_failures = [var.project_settings]
}

run "reject_invalid_vm_labels" {
  command = plan
  variables {
    compute_settings = {
      image  = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
      labels = { owner = "Invalid Value" }
    }
  }
  expect_failures = [var.compute_settings]
}

run "reject_reserved_snapshot_policy_label" {
  command = plan
  variables {
    snapshot_settings = { labels = { backup_policy = "manual" } }
  }
  expect_failures = [var.snapshot_settings]
}

run "null_labels_have_no_inheritance" {
  command = plan
  variables {
    project_settings = {
      project_id         = "fictional-crl-labels"
      billing_account_id = "000000-000000-000000"
      labels             = null
    }
    compute_settings = {
      image  = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
      labels = null
    }
    snapshot_settings = { labels = null }
  }
  assert {
    condition     = google_project.production[0].labels == tomap({ environment = "prod", managed_by = "terraform" }) && google_compute_instance_template.nginx.labels == google_project.production[0].labels && google_compute_resource_policy.daily_snapshot.snapshot_schedule_policy[0].snapshot_properties[0].labels == tomap({ environment = "prod", managed_by = "terraform", backup_policy = "crl-prod-daily" })
    error_message = "Labels null devem equivaler a mapas vazios, sem herança entre recursos."
  }
}
