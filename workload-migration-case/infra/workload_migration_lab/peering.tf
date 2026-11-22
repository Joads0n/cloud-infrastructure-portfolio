resource "google_compute_network_peering" "source_to_target" {
  name                 = "maple-source-to-target"
  network              = google_compute_network.source.self_link
  peer_network         = google_compute_network.target.self_link
  export_custom_routes = true
  import_custom_routes = true
}

resource "google_compute_network_peering" "target_to_source" {
  name                 = "maple-target-to-source"
  network              = google_compute_network.target.self_link
  peer_network         = google_compute_network.source.self_link
  export_custom_routes = true
  import_custom_routes = true
}
