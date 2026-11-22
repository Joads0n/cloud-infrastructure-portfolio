"""Verificações estáticas do contrato Terraform; não acessam o GCP."""

from pathlib import Path
import re
import unittest


CASE = Path(__file__).resolve().parents[1]
ROOT = CASE / "infra" / "secure_network_lab"


class ConfigurationContractTests(unittest.TestCase):
    def test_terraform_root_has_expected_responsibility_files(self):
        expected = {
            "apis.tf",
            "compute.tf",
            "connectivity_tests.tf",
            "dns.tf",
            "firewall_policies.tf",
            "locals.tf",
            "nat.tf",
            "network.tf",
            "ngfw.tf",
            "organization.tf",
            "outputs.tf",
            "providers.tf",
            "service_accounts.tf",
            "variables.tf",
            "versions.tf",
        }
        self.assertTrue(expected.issubset({path.name for path in ROOT.glob("*.tf")}))
        for path in ROOT.glob("*.tf"):
            with self.subTest(file=path.name):
                self.assertRegex(path.name, r"^[a-z][a-z0-9_]*\.tf$")

    def test_inputs_are_grouped_by_responsibility(self):
        source = (ROOT / "variables.tf").read_text()
        expected = {
            "platform_settings",
            "organization_settings",
            "project_settings",
            "network_settings",
            "compute_settings",
            "ngfw_settings",
            "test_settings",
        }
        self.assertEqual(set(re.findall(r'variable\s+"([^"]+)"', source)), expected)

    def test_projects_and_folder_are_explicitly_parameterized(self):
        source = (ROOT / "organization.tf").read_text()
        self.assertIn('resource "google_folder" "lab"', source)
        self.assertIn('resource "google_project" "apps"', source)
        self.assertIn('resource "google_project" "services"', source)
        self.assertIn("var.project_settings.create_projects", source)
        self.assertIn('deletion_policy = "DELETE"', source)
        self.assertIn("var.project_settings.billing_account_id", source)

    def test_network_topology_has_two_vpcs_subnets_and_bidirectional_peering(self):
        source = "\n".join(path.read_text() for path in ROOT.glob("*.tf"))
        for resource in (
            'google_compute_network" "apps',
            'google_compute_network" "services',
            'google_compute_subnetwork" "apps_application',
            'google_compute_subnetwork" "apps_test',
            'google_compute_subnetwork" "services',
            'google_compute_network_peering" "apps_to_services',
            'google_compute_network_peering" "services_to_apps',
        ):
            with self.subTest(resource=resource):
                self.assertIn(resource, source)
        self.assertIn("export_custom_routes = true", source)
        self.assertIn("import_custom_routes = true", source)

    def test_private_dns_and_nat_are_declared(self):
        dns = (ROOT / "dns.tf").read_text()
        nat = (ROOT / "nat.tf").read_text()
        self.assertIn('visibility  = "private"', dns)
        self.assertGreaterEqual(dns.count("network_url"), 2)
        self.assertEqual(nat.count('resource "google_compute_router_nat"'), 2)
        self.assertIn('nat_ip_allocate_option             = "AUTO_ONLY"', nat)

    def test_firewall_policy_contains_allow_deny_and_inspection_actions(self):
        source = (ROOT / "firewall_policies.tf").read_text()
        self.assertRegex(source, r'action\s*=\s*"allow"')
        self.assertRegex(source, r'action\s*=\s*"deny"')
        self.assertRegex(source, r'action\s*=\s*"apply_security_profile_group"')
        self.assertIn("security_profile_group", source)
        self.assertIn("enable_logging", source)
        self.assertGreaterEqual(source.count("google_compute_network_firewall_policy_association"), 2)
        self.assertGreaterEqual(source.count('direction       = "EGRESS"'), 6)
        self.assertGreaterEqual(source.count('rule_name       = "deny-unapproved-egress"'), 2)

    def test_ngfw_enterprise_and_ids_ips_are_mandatory(self):
        ngfw = (ROOT / "ngfw.tf").read_text()
        variables = (ROOT / "variables.tf").read_text()
        policy = (ROOT / "firewall_policies.tf").read_text()
        self.assertIn('type        = "THREAT_PREVENTION"', ngfw)
        self.assertIn('google_network_security_firewall_endpoint', ngfw)
        self.assertIn('google_network_security_firewall_endpoint_association', ngfw)
        self.assertRegex(variables, r"condition\s+=\s+var\.ngfw_settings\.enabled")
        self.assertIn("apply_security_profile_group", policy)

    def test_instances_have_no_public_ip_and_distinct_roles(self):
        source = (ROOT / "compute.tf").read_text()
        self.assertEqual(source.count('resource "google_compute_instance"'), 3)
        self.assertEqual(source.count("network_interface {"), 3)
        self.assertNotIn("access_config", source)
        self.assertEqual(source.count('enable-oslogin = "TRUE"'), 3)
        self.assertNotIn("cloud-platform", source)
        for role in ("application", "test", "orders-service"):
            with self.subTest(role=role):
                self.assertIn(f'role             = "{role}"', source)

    def test_connectivity_tests_cover_allowed_and_blocked_paths(self):
        source = (ROOT / "connectivity_tests.tf").read_text()
        self.assertIn('name     = "application-to-orders-http"', source)
        self.assertIn('name     = "test-to-orders-http"', source)
        self.assertEqual(source.count("google_network_management_connectivity_test"), 2)
        self.assertEqual(source.count("protocol = \"TCP\""), 2)

    def test_example_inputs_are_fictional_and_complete(self):
        example = (ROOT / "terraform.tfvars.example").read_text()
        for block in (
            "platform_settings",
            "organization_settings",
            "project_settings",
            "network_settings",
            "compute_settings",
            "ngfw_settings",
            "test_settings",
        ):
            with self.subTest(block=block):
                self.assertIn(f"{block} = {{", example)
        self.assertIn('enabled            = true', example)
        self.assertNotRegex(example, r"lab-portfolio-(dev|prd|mgmt)|prj-lab-test")
        self.assertNotIn("BEGIN PRIVATE KEY", example)

    def test_startup_script_contains_only_fixture_workload_behavior(self):
        source = (ROOT / "templates" / "startup.sh.tftpl").read_text()
        self.assertIn("apt-get install -y nginx curl ca-certificates", source)
        self.assertIn("add-google-cloud-ops-agent-repo.sh", source)
        self.assertNotIn("google-fluentd", source)
        self.assertIn("orders.json", source)
        self.assertIn("fictional", source)
        self.assertIn("systemctl enable nginx", source)


if __name__ == "__main__":
    unittest.main()
