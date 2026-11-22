"""Static contract tests for the fictional hybrid networking case."""

from pathlib import Path
import re
import unittest


CASE = Path(__file__).resolve().parents[1]
ROOT = CASE / "infra" / "hybrid_network_lab"


class HybridNetworkContractTests(unittest.TestCase):
    def test_root_files_use_responsibility_boundaries(self):
        expected = {
            "versions.tf", "providers.tf", "variables.tf", "locals.tf",
            "network.tf", "compute.tf", "vpn.tf", "firewall.tf", "outputs.tf",
            "terraform.tfvars.example",
        }
        self.assertTrue(expected.issubset({path.name for path in ROOT.iterdir()}))
        for path in ROOT.glob("*.tf"):
            self.assertRegex(path.name, r"^[a-z][a-z0-9_]*\.tf$")

    def test_vpn_and_bgp_redundancy_are_declared(self):
        source = "\n".join(path.read_text() for path in ROOT.glob("*.tf"))
        self.assertIn('google_compute_ha_vpn_gateway" "cloud', source)
        self.assertIn('redundancy_type = "TWO_IPS_REDUNDANCY"', source)
        self.assertEqual(source.count('resource "google_compute_vpn_tunnel"'), 2)
        self.assertEqual(source.count('resource "google_compute_router_peer"'), 2)
        self.assertEqual(source.count('ike_version                     = 2'), 2)

    def test_networks_are_private_and_firewall_is_explicit(self):
        network = (ROOT / "network.tf").read_text()
        firewall = (ROOT / "firewall.tf").read_text()
        self.assertIn("auto_create_subnetworks = false", network)
        self.assertIn("log_config", network)
        self.assertEqual(firewall.count('protocol = "tcp"'), 2)
        self.assertIn("peer_advertised_cidr", firewall)

    def test_example_is_fictional_and_safe(self):
        example = (ROOT / "terraform.tfvars.example").read_text()
        self.assertIn("198.51.100.10", example)
        self.assertIn("REPLACE_WITH_PRIVATE_SHARED_SECRET", example)
        self.assertNotIn("BEGIN PRIVATE KEY", example)
        self.assertNotRegex(example, r"(customer|employer|production-account)")


if __name__ == "__main__":
    unittest.main()
