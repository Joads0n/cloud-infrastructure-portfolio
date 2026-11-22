output "cloud_vpn_gateway_id" {
  description = "Cloud HA VPN gateway ID."
  value       = google_compute_ha_vpn_gateway.cloud.id
}

output "tunnel_ids" {
  description = "The two cloud-side VPN tunnel IDs."
  value = {
    tunnel_0 = google_compute_vpn_tunnel.tunnel_0.id
    tunnel_1 = google_compute_vpn_tunnel.tunnel_1.id
  }
}

output "bgp_peer_names" {
  description = "Cloud Router BGP peer names."
  value = [
    google_compute_router_peer.tunnel_0.name,
    google_compute_router_peer.tunnel_1.name,
  ]
}

output "cloud_service_private_ip" {
  description = "Private address of the optional cloud fixture."
  value       = try(google_compute_instance.cloud_service[0].network_interface[0].network_ip, null)
}
