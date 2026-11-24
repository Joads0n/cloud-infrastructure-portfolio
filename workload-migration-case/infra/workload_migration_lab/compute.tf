resource "google_compute_instance_group" "target" {
  name        = "${local.prefix}-target-group"
  zone        = local.zone
  description = "Grupo não gerenciado para as duas VMs de destino do M2VM."
  instances   = local.target_instance_self_links

  named_port {
    name = "http"
    port = 80
  }
}
