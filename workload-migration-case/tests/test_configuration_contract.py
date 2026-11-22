"""Static contract tests for the synthetic workload migration case."""

from pathlib import Path
import unittest


CASE = Path(__file__).resolve().parents[1]
ROOT = CASE / "infra" / "workload_migration_lab"


class WorkloadMigrationContractTests(unittest.TestCase):
    def test_root_has_migration_responsibility_files(self):
        expected = {
            "versions.tf", "providers.tf", "variables.tf", "locals.tf", "apis.tf",
            "network.tf", "peering.tf", "compute.tf", "load_balancer.tf", "dns.tf",
            "artifacts.tf", "firewall.tf", "outputs.tf", "terraform.tfvars.example",
        }
        self.assertTrue(expected.issubset({path.name for path in ROOT.iterdir()}))

    def test_source_target_and_peering_are_explicit(self):
        network = (ROOT / "network.tf").read_text()
        peering = (ROOT / "peering.tf").read_text()
        compute = (ROOT / "compute.tf").read_text()
        self.assertGreaterEqual(network.count('resource "google_compute_network"'), 2)
        self.assertEqual(peering.count('resource "google_compute_network_peering"'), 2)
        self.assertIn('resource "google_compute_instance" "source"', compute)
        self.assertIn('resource "google_compute_region_instance_group_manager" "target"', compute)
        self.assertNotIn("access_config", compute)

    def test_cutover_and_rollback_controls_exist(self):
        variables = (ROOT / "variables.tf").read_text()
        dns = (ROOT / "dns.tf").read_text()
        self.assertIn("active_backend", variables)
        self.assertIn('contains(["source", "target"]', variables)
        self.assertIn('active_backend == "target"', dns)
        self.assertIn("google_dns_record_set", dns)

    def test_target_traffic_and_artifact_controls_exist(self):
        load_balancer = (ROOT / "load_balancer.tf").read_text()
        artifacts = (ROOT / "artifacts.tf").read_text()
        firewall = (ROOT / "firewall.tf").read_text()
        self.assertIn("google_compute_region_health_check", load_balancer)
        self.assertIn("google_compute_forwarding_rule", load_balancer)
        self.assertIn("uniform_bucket_level_access = true", artifacts)
        self.assertIn('public_access_prevention    = "enforced"', artifacts)
        self.assertIn("versioning", artifacts)
        self.assertIn("source_subnet_cidr", firewall)

    def test_example_is_synthetic_and_safe(self):
        example = (ROOT / "terraform.tfvars.example").read_text()
        self.assertIn("prj-maple-migration-lab", example)
        self.assertIn("10.80.10.0/24", example)
        self.assertIn("active_backend          = \"source\"", example)
        self.assertNotIn("BEGIN PRIVATE KEY", example)


if __name__ == "__main__":
    unittest.main()
