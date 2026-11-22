resource "google_compute_instance" "application" {
  provider     = google.apps
  project      = local.apps_project_id
  name         = var.compute_settings.application_name
  zone         = var.platform_settings.zones[0]
  machine_type = var.compute_settings.machine_type
  tags         = ["application", "os-login-managed"]
  metadata = {
    enable-oslogin = "TRUE"
  }

  boot_disk {
    initialize_params {
      image = var.compute_settings.image
      size  = var.compute_settings.boot_disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.apps_application.id
  }

  metadata_startup_script = templatefile("${path.module}/templates/startup.sh.tftpl", {
    role             = "application"
    service_hostname = var.network_settings.service_record_name
  })

  service_account {
    email = google_service_account.apps_runtime.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  labels     = merge(local.common_labels, { role = "application" })
  depends_on = [google_project_iam_member.apps_logging, google_project_iam_member.apps_monitoring]
}

resource "google_compute_instance" "test" {
  provider     = google.apps
  project      = local.apps_project_id
  name         = var.compute_settings.test_name
  zone         = var.platform_settings.zones[1]
  machine_type = var.compute_settings.machine_type
  tags         = ["test", "os-login-managed"]
  metadata = {
    enable-oslogin = "TRUE"
  }

  boot_disk {
    initialize_params {
      image = var.compute_settings.image
      size  = var.compute_settings.boot_disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.apps_test.id
  }

  metadata_startup_script = templatefile("${path.module}/templates/startup.sh.tftpl", {
    role             = "test"
    service_hostname = var.network_settings.service_record_name
  })

  service_account {
    email = google_service_account.apps_runtime.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  labels     = merge(local.common_labels, { role = "test" })
  depends_on = [google_project_iam_member.apps_logging, google_project_iam_member.apps_monitoring]
}

resource "google_compute_instance" "orders" {
  provider     = google.services
  project      = local.services_project_id
  name         = var.compute_settings.service_name
  zone         = var.platform_settings.zones[0]
  machine_type = var.compute_settings.machine_type
  tags         = ["orders-service", "os-login-managed"]
  metadata = {
    enable-oslogin = "TRUE"
  }

  boot_disk {
    initialize_params {
      image = var.compute_settings.image
      size  = var.compute_settings.boot_disk_size_gb
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.services.id
  }

  metadata_startup_script = templatefile("${path.module}/templates/startup.sh.tftpl", {
    role             = "orders-service"
    service_hostname = var.network_settings.service_record_name
  })

  service_account {
    email = google_service_account.services_runtime.email
    scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
    ]
  }

  labels     = merge(local.common_labels, { role = "orders-service" })
  depends_on = [google_project_iam_member.services_logging, google_project_iam_member.services_monitoring]
}
