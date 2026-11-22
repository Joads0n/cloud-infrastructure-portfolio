resource "google_compute_network_firewall_policy" "apps" {
  provider    = google-beta.apps
  project     = local.apps_project_id
  name        = "apps-network-policy"
  description = "Controles de saída da VPC de aplicações."
  depends_on  = [google_project_service.apps]
}

resource "google_compute_network_firewall_policy_association" "apps" {
  provider          = google-beta.apps
  name              = "apps-policy-association"
  firewall_policy   = google_compute_network_firewall_policy.apps.id
  attachment_target = google_compute_network.apps.id
}

resource "google_compute_network_firewall_policy_rule" "apps_egress_orders" {
  provider        = google-beta.apps
  firewall_policy = google_compute_network_firewall_policy.apps.name
  priority        = 1000
  action          = "allow"
  direction       = "EGRESS"
  rule_name       = "allow-orders-http"
  enable_logging  = true

  match {
    dest_ip_ranges = [var.network_settings.services_cidr]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80"]
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "apps_egress_web" {
  provider        = google-beta.apps
  firewall_policy = google_compute_network_firewall_policy.apps.name
  priority        = 1100
  action          = "allow"
  direction       = "EGRESS"
  rule_name       = "allow-bootstrap-and-telemetry-web"
  enable_logging  = true

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80", "443"]
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "apps_egress_dns" {
  provider        = google-beta.apps
  firewall_policy = google_compute_network_firewall_policy.apps.name
  priority        = 1110
  action          = "allow"
  direction       = "EGRESS"
  rule_name       = "allow-dns-resolution"
  enable_logging  = true

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "udp"
      ports       = ["53"]
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "apps_egress_deny" {
  provider        = google-beta.apps
  firewall_policy = google_compute_network_firewall_policy.apps.name
  priority        = 1200
  action          = "deny"
  direction       = "EGRESS"
  rule_name       = "deny-unapproved-egress"
  enable_logging  = true

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_network_firewall_policy" "services" {
  provider    = google-beta.services
  project     = local.services_project_id
  name        = "services-network-policy"
  description = "Controles de entrada e inspeção da VPC de serviços internos."
  depends_on  = [google_project_service.services]
}

resource "google_compute_network_firewall_policy_association" "services" {
  provider          = google-beta.services
  name              = "services-policy-association"
  firewall_policy   = google_compute_network_firewall_policy.services.id
  attachment_target = google_compute_network.services.id
}

resource "google_compute_network_firewall_policy_rule" "services_deny_test" {
  provider        = google-beta.services
  firewall_policy = google_compute_network_firewall_policy.services.name
  priority        = 900
  action          = "deny"
  direction       = "INGRESS"
  rule_name       = "deny-test-to-orders"
  enable_logging  = true

  match {
    src_ip_ranges  = [var.network_settings.apps_test_cidr]
    dest_ip_ranges = [var.network_settings.services_cidr]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80"]
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "services_egress_web" {
  provider        = google-beta.services
  firewall_policy = google_compute_network_firewall_policy.services.name
  priority        = 2000
  action          = "allow"
  direction       = "EGRESS"
  rule_name       = "allow-bootstrap-and-telemetry-web"
  enable_logging  = true

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80", "443"]
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "services_egress_dns" {
  provider        = google-beta.services
  firewall_policy = google_compute_network_firewall_policy.services.name
  priority        = 2010
  action          = "allow"
  direction       = "EGRESS"
  rule_name       = "allow-dns-resolution"
  enable_logging  = true

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "udp"
      ports       = ["53"]
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "services_egress_deny" {
  provider        = google-beta.services
  firewall_policy = google_compute_network_firewall_policy.services.name
  priority        = 2100
  action          = "deny"
  direction       = "EGRESS"
  rule_name       = "deny-unapproved-egress"
  enable_logging  = true

  match {
    dest_ip_ranges = ["0.0.0.0/0"]

    layer4_configs {
      ip_protocol = "all"
    }
  }
}

resource "google_compute_network_firewall_policy_rule" "services_inspect_application" {
  provider               = google-beta.services
  firewall_policy        = google_compute_network_firewall_policy.services.name
  priority               = 1000
  action                 = "apply_security_profile_group"
  direction              = "INGRESS"
  rule_name              = "inspect-application-to-orders"
  enable_logging         = var.ngfw_settings.enable_logging
  security_profile_group = google_network_security_security_profile_group.threat_prevention.id

  match {
    src_ip_ranges  = [var.network_settings.apps_application_cidr]
    dest_ip_ranges = [var.network_settings.services_cidr]

    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80"]
    }
  }
}

resource "google_compute_firewall" "services_allow_internal" {
  provider      = google.services
  project       = local.services_project_id
  name          = "services-allow-internal"
  network       = google_compute_network.services.name
  direction     = "INGRESS"
  source_ranges = [var.network_settings.apps_application_cidr]

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
}

resource "google_compute_firewall" "services_allow_iap_ssh" {
  provider      = google.services
  project       = local.services_project_id
  name          = "services-allow-iap-ssh"
  network       = google_compute_network.services.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["os-login-managed"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "apps_allow_iap_ssh" {
  provider      = google.apps
  project       = local.apps_project_id
  name          = "apps-allow-iap-ssh"
  network       = google_compute_network.apps.name
  direction     = "INGRESS"
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["os-login-managed"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}
