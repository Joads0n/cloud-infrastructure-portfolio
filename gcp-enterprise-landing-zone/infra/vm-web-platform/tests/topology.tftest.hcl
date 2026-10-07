mock_provider "google" {}
mock_provider "google-beta" {}

variables {
  project_settings = {
    project_id     = "fictional-crl-tests"
    create_project = false
  }

  deployment_settings = {
    environment = "prod"
  }

  compute_settings = {
    backend_count = 2
    image         = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
  }

  load_balancer_settings = {
    allow_public_http = true
  }
}

run "external_lb_private_replicas" {
  command = plan
  assert {
    condition     = google_compute_global_forwarding_rule.app[0].load_balancing_scheme == "EXTERNAL_MANAGED" && google_compute_backend_service.app.load_balancing_scheme == "EXTERNAL_MANAGED"
    error_message = "Use o Application Load Balancer global externo."
  }
  assert {
    condition     = google_compute_region_instance_group_manager.nginx.target_size == 2 && length(google_compute_region_instance_group_manager.nginx.distribution_policy_zones) == 2 && length(google_compute_instance_template.nginx.network_interface[0].access_config) == 0
    error_message = "Use duas réplicas privadas distribuídas em duas zonas."
  }
  assert {
    condition     = google_compute_instance_template.nginx.machine_type == "e2-micro" && google_compute_instance_template.nginx.disk[0].disk_size_gb == 10 && google_compute_instance_template.nginx.metadata["enable-oslogin"] == "TRUE"
    error_message = "Mantenha o dimensionamento de laboratório e o OS Login."
  }
}

run "scale_to_three" {
  command = plan
  variables {
    compute_settings = {
      backend_count = 3
      image         = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
    }
  }
  assert {
    condition     = google_compute_region_instance_group_manager.nginx.target_size == 3
    error_message = "Permita expansão manual limitada."
  }
}

run "reject_public_http_without_acceptance" {
  command = plan
  variables {
    load_balancer_settings = {
      allow_public_http = false
    }
  }
  expect_failures = [google_compute_instance_template.nginx]
}

run "reject_unbounded_scale" {
  command = plan
  variables {
    compute_settings = {
      backend_count = 4
      image         = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
    }
  }
  expect_failures = [var.compute_settings]
}

run "reject_dev" {
  command = plan
  variables {
    deployment_settings = {
      environment = "dev"
    }
  }
  expect_failures = [var.deployment_settings]
}

run "reject_moving_image" {
  command = plan
  variables {
    compute_settings = {
      backend_count = 2
      image         = "projects/debian-cloud/global/images/family/debian-12"
    }
  }
  expect_failures = [var.compute_settings]
}

run "reject_duplicate_vm_zones" {
  command = plan
  variables {
    compute_settings = {
      image = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
      zones = ["us-central1-a", "us-central1-a"]
    }
  }
  expect_failures = [var.compute_settings]
}
