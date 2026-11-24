"""Testes estáticos do contrato do case de migração de VMs AWS para GCP."""

from pathlib import Path
import unittest


CASE = Path(__file__).resolve().parents[1]
ROOT = CASE / "infra" / "workload_migration_lab"


class WorkloadMigrationContractTests(unittest.TestCase):
    def test_root_has_project_m2vm_network_and_lb_files(self):
        expected = {
            "versions.tf", "providers.tf", "variables.tf", "locals.tf", "project.tf",
            "network.tf", "m2vm.tf", "compute.tf", "load_balancer.tf", "dns.tf",
            "firewall.tf", "outputs.tf", "terraform.tfvars.example",
        }
        self.assertTrue(expected.issubset({path.name for path in ROOT.iterdir()}))

    def test_case_is_gcp_only_and_does_not_provision_vms(self):
        versions = (ROOT / "versions.tf").read_text()
        compute = (ROOT / "compute.tf").read_text()
        variables = (ROOT / "variables.tf").read_text()
        self.assertIn('source  = "hashicorp/google"', versions)
        self.assertNotIn('source  = "hashicorp/aws"', versions)
        self.assertNotIn('resource "google_compute_instance"', compute)
        self.assertIn("target_instance_self_links", variables)

    def test_source_is_two_existing_aws_vms_with_lb_and_nat_contract(self):
        variables = (ROOT / "variables.tf").read_text()
        m2vm = (ROOT / "m2vm.tf").read_text()
        example = (ROOT / "terraform.tfvars.example").read_text()
        self.assertIn("source_vm_count", variables)
        self.assertIn("source_has_load_balancer", variables)
        self.assertIn("source_has_nat_egress", variables)
        self.assertIn("source_vm_count", m2vm)
        self.assertIn("source_load_balancer", m2vm)
        self.assertIn("source_nat_egress", m2vm)
        self.assertIn("source_vm_count           = 2", example)
        self.assertIn("source_has_load_balancer  = true", example)
        self.assertIn("source_has_nat_egress     = true", example)

    def test_project_apis_and_m2vm_contract_are_explicit(self):
        project = (ROOT / "project.tf").read_text()
        m2vm = (ROOT / "m2vm.tf").read_text()
        locals_text = (ROOT / "locals.tf").read_text()
        self.assertIn('resource "google_project" "destination"', project)
        self.assertNotIn('alias                 = "bootstrap"', (ROOT / "providers.tf").read_text())
        self.assertNotIn("platform_settings", (ROOT / "variables.tf").read_text())
        self.assertIn('"vmmigration.googleapis.com"', locals_text)
        self.assertIn("m2vm_aws_source_contract", m2vm)
        self.assertIn("aws_region", m2vm)

    def test_private_network_nat_firewall_and_global_lb_exist(self):
        network = (ROOT / "network.tf").read_text()
        firewall = (ROOT / "firewall.tf").read_text()
        load_balancer = (ROOT / "load_balancer.tf").read_text()
        compute = (ROOT / "compute.tf").read_text()
        self.assertIn('resource "google_compute_router_nat" "target"', network)
        self.assertIn('source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]', firewall)
        self.assertIn('resource "google_compute_global_forwarding_rule" "target"', load_balancer)
        self.assertIn('load_balancing_scheme = "EXTERNAL_MANAGED"', load_balancer)
        self.assertIn('resource "google_compute_instance_group" "target"', compute)

    def test_m2vm_destination_backend_accepts_zero_or_two_migrated_vms(self):
        variables = (ROOT / "variables.tf").read_text()
        compute = (ROOT / "compute.tf").read_text()
        self.assertIn("length(var.m2vm_settings.target_instance_self_links) == 0", variables)
        self.assertIn("|| length(var.m2vm_settings.target_instance_self_links) == 2", variables)
        self.assertIn("instances   = local.target_instance_self_links", compute)

    def test_global_lb_is_front_door_for_the_migrated_vm_group(self):
        load_balancer = (ROOT / "load_balancer.tf").read_text()
        self.assertIn("google_compute_instance_group.target.id", load_balancer)
        self.assertIn("google_compute_health_check.target.id", load_balancer)
        self.assertIn("google_compute_url_map", load_balancer)
        self.assertIn("google_compute_target_http_proxy", load_balancer)
        self.assertIn("google_compute_global_forwarding_rule", load_balancer)

    def test_cutover_and_rollback_are_explicit(self):
        variables = (ROOT / "variables.tf").read_text()
        dns = (ROOT / "dns.tf").read_text()
        example = (ROOT / "terraform.tfvars.example").read_text()
        self.assertIn('contains(["aws", "gcp"]', variables)
        self.assertIn('active_backend == "gcp"', dns)
        self.assertIn('active_backend      = "aws"', example)
        self.assertIn('fictional_source_ip', example)

    def test_example_contains_no_credentials_or_real_aws_data(self):
        example = (ROOT / "terraform.tfvars.example").read_text()
        self.assertIn("create_project     = true", example)
        self.assertNotIn("platform_settings", example)
        self.assertNotIn("fictional-bootstrap", example)
        self.assertIn("organization_id    = null", example)
        self.assertIn("folder_id          = null", example)
        self.assertIn("billing_account_id =", example)
        self.assertIn("resource_prefix =", example)
        self.assertIn("environment     =", example)
        self.assertIn("region          =", example)
        self.assertIn("labels = {", example)
        self.assertIn("sg-fictional-m2vm-source", example)
        self.assertNotIn("aws_access_key", example.lower())
        self.assertNotIn("secret_access_key", example.lower())
        self.assertNotIn("BEGIN PRIVATE KEY", example)


if __name__ == "__main__":
    unittest.main()
