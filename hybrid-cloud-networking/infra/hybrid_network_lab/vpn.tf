resource "google_compute_ha_vpn_gateway" "cloud" {
  name    = "orion-ha-vpn"
  network = google_compute_network.cloud.id
  region  = var.platform_settings.region
}

resource "google_compute_external_vpn_gateway" "peer" {
  name            = var.vpn_settings.peer_external_gateway
  redundancy_type = "TWO_IPS_REDUNDANCY"

  interface {
    id         = 0
    ip_address = var.vpn_settings.peer_ip_0
  }

  interface {
    id         = 1
    ip_address = var.vpn_settings.peer_ip_1
  }
}

resource "google_compute_router" "cloud" {
  name    = "orion-cloud-router"
  region  = var.platform_settings.region
  network = google_compute_network.cloud.id

  bgp {
    asn = var.vpn_settings.cloud_asn
  }
}

resource "google_compute_vpn_tunnel" "tunnel_0" {
  name                            = "orion-tunnel-0"
  region                          = var.platform_settings.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.cloud.id
  vpn_gateway_interface           = 0
  peer_external_gateway           = google_compute_external_vpn_gateway.peer.id
  peer_external_gateway_interface = 0
  shared_secret                   = var.vpn_settings.shared_secret
  ike_version                     = 2
  router                          = google_compute_router.cloud.id
  local_traffic_selector          = [var.network_settings.cloud_subnet_cidr]
  remote_traffic_selector         = [var.network_settings.peer_advertised_cidr]
}

resource "google_compute_vpn_tunnel" "tunnel_1" {
  name                            = "orion-tunnel-1"
  region                          = var.platform_settings.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.cloud.id
  vpn_gateway_interface           = 1
  peer_external_gateway           = google_compute_external_vpn_gateway.peer.id
  peer_external_gateway_interface = 1
  shared_secret                   = var.vpn_settings.shared_secret
  ike_version                     = 2
  router                          = google_compute_router.cloud.id
  local_traffic_selector          = [var.network_settings.cloud_subnet_cidr]
  remote_traffic_selector         = [var.network_settings.peer_advertised_cidr]
}

resource "google_compute_router_interface" "tunnel_0" {
  name       = "orion-bgp-interface-0"
  router     = google_compute_router.cloud.name
  region     = var.platform_settings.region
  ip_range   = "${var.vpn_settings.cloud_bgp_ip_0}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel_0.name
}

resource "google_compute_router_interface" "tunnel_1" {
  name       = "orion-bgp-interface-1"
  router     = google_compute_router.cloud.name
  region     = var.platform_settings.region
  ip_range   = "${var.vpn_settings.cloud_bgp_ip_1}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel_1.name
}

resource "google_compute_router_peer" "tunnel_0" {
  name                      = "orion-bgp-peer-0"
  router                    = google_compute_router.cloud.name
  region                    = var.platform_settings.region
  peer_ip_address           = var.vpn_settings.peer_bgp_ip_0
  peer_asn                  = var.vpn_settings.peer_asn
  interface                 = google_compute_router_interface.tunnel_0.name
  advertised_route_priority = 100
}

resource "google_compute_router_peer" "tunnel_1" {
  name                      = "orion-bgp-peer-1"
  router                    = google_compute_router.cloud.name
  region                    = var.platform_settings.region
  peer_ip_address           = var.vpn_settings.peer_bgp_ip_1
  peer_asn                  = var.vpn_settings.peer_asn
  interface                 = google_compute_router_interface.tunnel_1.name
  advertised_route_priority = 100
}
