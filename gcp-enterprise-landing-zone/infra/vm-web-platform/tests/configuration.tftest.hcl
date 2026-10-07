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

run "custom_deployment_values" {
  command = plan
  variables {
    deployment_settings = {
      environment     = "prod"
      resource_prefix = "example-prod"
      region          = "us-east1"
    }

    network_settings = {
      subnet_cidr = "10.90.20.0/24"
      vpc_name    = "example-network"
      subnet_name = "example-subnet"
    }

    compute_settings = {
      backend_count     = 2
      image             = "projects/debian-cloud/global/images/debian-12-fictional-test-fixture"
      vm_base_name      = "example-web"
      zones             = ["us-east1-b", "us-east1-c"]
      labels            = { owner = "example-team" }
      machine_type      = "e2-small"
      boot_disk_size_gb = 20
    }

    application_settings = {
      hostname = "app.example.test"
    }

    load_balancer_settings = {
      allow_public_http       = true
      lb_name                 = "example-edge"
      backend_max_utilization = 0.7
    }

    snapshot_settings = {
      start_time     = "06:00"
      retention_days = 3
      location       = "us"
    }
  }
  assert {
    condition     = google_compute_network.workload.name == "example-network" && google_compute_subnetwork.workload.name == "example-subnet" && google_compute_subnetwork.workload.ip_cidr_range == "10.90.20.0/24" && google_compute_subnetwork.workload.region == "us-east1"
    error_message = "Os valores da rede devem seguir os parâmetros do usuário."
  }
  assert {
    condition     = google_compute_region_instance_group_manager.nginx.base_instance_name == "example-web" && toset(google_compute_region_instance_group_manager.nginx.distribution_policy_zones) == toset(["us-east1-b", "us-east1-c"]) && google_compute_instance_template.nginx.machine_type == "e2-small" && google_compute_instance_template.nginx.disk[0].disk_size_gb == 20
    error_message = "Nomes, dimensionamento e localização das VMs devem seguir os parâmetros do usuário."
  }
  assert {
    condition     = google_compute_global_address.app.name == "example-edge" && google_compute_target_http_proxy.app[0].name == "example-edge" && alltrue([for backend in google_compute_backend_service.app.backend : backend.max_utilization == 0.7])
    error_message = "O nome e a utilização do LB devem seguir os parâmetros do usuário."
  }
  assert {
    condition     = google_compute_resource_policy.daily_snapshot.snapshot_schedule_policy[0].schedule[0].daily_schedule[0].start_time == "06:00" && google_compute_resource_policy.daily_snapshot.snapshot_schedule_policy[0].retention_policy[0].max_retention_days == 3 && google_compute_instance_template.nginx.labels["owner"] == "example-team"
    error_message = "As configurações de snapshots e labels personalizadas devem seguir os parâmetros do usuário."
  }
  assert {
    condition     = strcontains(google_compute_instance_template.nginx.metadata_startup_script, "server_name app.example.test;")
    error_message = "O nome de host informado deve ser repassado à configuração de inicialização do Nginx."
  }
}

run "https_only" {
  command = plan
  variables {
    application_settings = {
      hostname = "app.example.test"
    }

    load_balancer_settings = {
      allow_public_http   = false
      enable_http         = false
      enable_https        = true
      ssl_certificate_ids = ["projects/fictional-example-prod/global/sslCertificates/example-cert"]
    }
  }
  assert {
    condition     = length(google_compute_target_http_proxy.app) == 0 && length(google_compute_global_forwarding_rule.app) == 0 && length(google_compute_target_https_proxy.app) == 1 && google_compute_global_forwarding_rule.https[0].port_range == "443"
    error_message = "HTTPS exclusivo não deve expor a porta 80."
  }
  assert {
    condition     = output.endpoint == "https://app.example.test" && google_compute_backend_service.app.protocol == "HTTP" && google_compute_target_https_proxy.app[0].ssl_certificates[0] == "projects/fictional-example-prod/global/sslCertificates/example-cert"
    error_message = "Termine TLS com o certificado informado e preserve o backend HTTP privado."
  }
}

run "both_frontends" {
  command = plan
  variables {
    load_balancer_settings = {
      allow_public_http   = true
      enable_http         = true
      enable_https        = true
      ssl_certificate_ids = ["projects/fictional-example-prod/global/sslCertificates/example-cert"]
    }
  }
  assert {
    condition     = length(google_compute_global_forwarding_rule.app) == 1 && length(google_compute_global_forwarding_rule.https) == 1
    error_message = "Ambos os frontends habilitados explicitamente devem existir."
  }
}

run "reject_missing_certificate" {
  command = plan
  variables {
    load_balancer_settings = {
      allow_public_http = true
      enable_https      = true
    }
  }
  expect_failures = [var.load_balancer_settings]
}

run "reject_no_frontend" {
  command = plan
  variables {
    load_balancer_settings = {
      allow_public_http = true
      enable_http       = false
    }
  }
  expect_failures = [var.load_balancer_settings]
}

run "reject_wrong_zone_region" {
  command = plan
  variables {
    deployment_settings = {
      environment = "prod"
      region      = "us-east1"
    }
  }
  expect_failures = [var.compute_settings]
}

run "reject_public_subnet" {
  command = plan
  variables {
    network_settings = {
      subnet_cidr = "8.8.8.0/24"
    }
  }
  expect_failures = [var.network_settings]
}

run "reject_hostname_injection" {
  command = plan
  variables {
    application_settings = {
      hostname = "app.example.test; reboot"
    }
  }
  expect_failures = [var.application_settings]
}

run "reject_reserved_labels" {
  command = plan
  variables {
    snapshot_settings = {
      labels = { environment = "dev" }
    }
  }
  expect_failures = [var.snapshot_settings]
}
