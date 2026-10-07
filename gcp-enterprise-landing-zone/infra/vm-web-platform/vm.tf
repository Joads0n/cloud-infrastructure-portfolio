resource "google_compute_instance_template" "nginx" {
  depends_on     = [google_project_service.required, google_project_service.monitoring, google_project_iam_member.telemetry]
  provider       = google-beta
  name_prefix    = "${local.vm_name}-"
  machine_type   = var.compute_settings.machine_type
  enable_display = var.compute_settings.enable_display
  tags           = ["${local.prefix}-nginx"]
  labels         = local.vm_labels
  disk {
    source_image      = var.compute_settings.image
    boot              = true
    auto_delete       = true
    disk_type         = var.compute_settings.boot_disk_type
    disk_size_gb      = var.compute_settings.boot_disk_size_gb
    resource_policies = [google_compute_resource_policy.daily_snapshot.id]
  }
  network_interface {
    subnetwork = google_compute_subnetwork.workload.id
    # Sem access_config: as VMs dos backends nunca recebem IPs externos.
  }
  service_account {
    email  = google_service_account.runtime.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
  metadata = {
    enable-oslogin         = "TRUE"
    block-project-ssh-keys = "TRUE"
    serial-port-enable     = "FALSE"
  }
  metadata_startup_script = templatefile("${path.module}/templates/startup.sh.tftpl", {
    page     = base64encode(templatefile("${path.module}/templates/index.html.tftpl", { environment = var.deployment_settings.environment }))
    hostname = local.hostname
  })
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }
  lifecycle {
    create_before_destroy = true
    precondition {
      condition     = !var.load_balancer_settings.enable_http || var.load_balancer_settings.allow_public_http
      error_message = "HTTP público exige aceite explícito para o laboratório. Use somente conteúdo fictício e não sensível."
    }
  }
}
