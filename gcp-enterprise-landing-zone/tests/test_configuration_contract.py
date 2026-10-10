"""Verificações estáticas do repasse de parâmetros; sem planos Terraform nem chamadas à nuvem."""
from pathlib import Path
import re
import unittest

INFRA = Path(__file__).resolve().parents[1] / "infra"
ROOT = INFRA / "vm-web-platform"


class ConfigurationContractTests(unittest.TestCase):
    def test_independent_project_and_vm_labels(self):
        for name, label_source in (("project.tf", "project_labels"),
                                   ("vm.tf", "vm_labels")):
            with self.subTest(file=name):
                self.assertRegex((ROOT / name).read_text(),
                                 rf"labels\s*=\s*local\.{label_source}\b")
        source = (ROOT / "locals.tf").read_text()
        for group in ("project_settings", "compute_settings"):
            self.assertIn(f"merge(var.{group}.labels,", source)
        self.assertNotIn("var.deployment_settings.labels", source)
        self.assertRegex(source, r"zones\s*=\s*var\.compute_settings\.zones")
        self.assertIn("merge(var.snapshot_settings.labels, local.labels,", (ROOT / "snapshots.tf").read_text())

    def test_root_passes_configuration_and_region(self):
        source = (ROOT / "providers.tf").read_text()
        self.assertEqual(source.count("region  = var.deployment_settings.region"), 2)
        source = (ROOT / "service_account.tf").read_text()
        self.assertIn("account_id   = var.identity_settings.runtime_service_account_id", source)

    def test_resource_logic_has_no_case_specific_deployment_literals(self):
        for name in ("network.tf", "nat.tf", "firewall.tf", "vm.tf", "mig.tf", "load_balancers.tf", "snapshots.tf"):
            source = (ROOT / name).read_text()
            for literal in ('"crl-', '"us-central1"', '"10.80.10.0/24"',
                            '"app.cedar-route.example"', '"e2-micro"', '"pd-standard"'):
                with self.subTest(file=name, literal=literal):
                    self.assertNotIn(literal, source)

    def test_project_ownership_is_explicit(self):
        source = (ROOT / "project.tf").read_text()
        self.assertRegex(source, r"count\s*=\s*var.project_settings.create_project \? 1 : 0")
        self.assertRegex(source, r'deletion_policy\s*=\s*"DELETE"')
        self.assertIn("google_project.production[0].project_id : var.project_settings.project_id", source)

    def test_inputs_are_grouped_by_responsibility(self):
        source = "\n".join(p.read_text() for p in ROOT.glob("*.tf"))
        expected = {"project_settings", "deployment_settings", "network_settings",
                    "compute_settings", "application_settings", "load_balancer_settings",
                    "snapshot_settings", "identity_settings"}
        self.assertEqual(set(re.findall(r'variable\s+"([^"]+)"', source)), expected)
        self.assertNotRegex(source, r"var\.settings\b")
        self.assertNotIn("-var='backend_count=", (ROOT.parent / "README.md").read_text())

    def test_resource_groups_have_separate_files(self):
        for path in ROOT.glob("*.tf"):
            with self.subTest(file=path.name):
                self.assertRegex(path.name, r"^[a-z][a-z0-9_]*\.tf$")
        for name in ("network", "nat", "firewall", "vm", "mig", "load_balancers", "snapshots"):
            self.assertIn('resource "', (ROOT / f"{name}.tf").read_text())
        source = "\n".join(p.read_text() for p in ROOT.glob("*.tf"))
        self.assertNotRegex(source, r'(?m)^module\s+"')

    def test_compute_resources_keep_dependencies_and_address_mappings(self):
        mappings = (ROOT / "migrations.tf").read_text()
        for path in ROOT.glob("*.tf"):
            source = path.read_text()
            for kind, name in re.findall(r'resource "(google_compute_[^"]+)" "([^"]+)"', source):
                with self.subTest(resource=f"{kind}.{name}"):
                    self.assertRegex(mappings, rf"from\s*=\s*module\.nginx\.{kind}\.{name}\b")
                    self.assertRegex(mappings, rf"to\s*=\s*{kind}\.{name}\b")
                    self.assertIn("google_project_service.required", source)
                    self.assertIn("google_project_service.monitoring", source)
                    self.assertIn("google_project_iam_member.telemetry", source)


if __name__ == "__main__":
    unittest.main()
