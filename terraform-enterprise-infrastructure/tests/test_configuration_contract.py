"""Static contract tests for the Terraform platform foundation."""

from pathlib import Path
import unittest


CASE = Path(__file__).resolve().parents[1]
ROOT = CASE / "infra" / "terraform_enterprise_lab"


class TerraformEnterpriseContractTests(unittest.TestCase):
    def test_root_has_expected_responsibility_files(self):
        expected = {
            "versions.tf", "providers.tf", "variables.tf", "locals.tf", "apis.tf",
            "network.tf", "nat.tf", "database.tf", "security.tf", "artifacts.tf",
            "compute.tf", "outputs.tf", "terraform.tfvars.example",
        }
        self.assertTrue(expected.issubset({path.name for path in ROOT.iterdir()}))

    def test_private_network_and_private_service_access_are_declared(self):
        network = (ROOT / "network.tf").read_text()
        compute = (ROOT / "compute.tf").read_text()
        database = (ROOT / "database.tf").read_text()
        self.assertIn("auto_create_subnetworks = false", network)
        self.assertIn('purpose       = "VPC_PEERING"', network)
        self.assertIn("google_service_networking_connection", network)
        self.assertNotIn("access_config", compute)
        self.assertIn("ipv4_enabled                                  = false", database)
        self.assertIn("private_network", database)

    def test_data_protection_controls_are_present(self):
        database = (ROOT / "database.tf").read_text()
        artifacts = (ROOT / "artifacts.tf").read_text()
        self.assertIn("point_in_time_recovery_enabled = true", database)
        self.assertIn("backup_retention_settings", database)
        self.assertIn("default_kms_key_name", artifacts)
        self.assertIn("public_access_prevention    = \"enforced\"", artifacts)
        self.assertIn("uniform_bucket_level_access = true", artifacts)
        self.assertIn("versioning", artifacts)

    def test_identity_and_secret_boundaries_are_explicit(self):
        security = (ROOT / "security.tf").read_text()
        artifacts = (ROOT / "artifacts.tf").read_text()
        compute = (ROOT / "compute.tf").read_text()
        example = (ROOT / "terraform.tfvars.example").read_text()
        self.assertIn("google_service_account\" \"runtime", security)
        self.assertIn("google_storage_bucket_iam_member\" \"runtime", artifacts)
        self.assertIn('enable-oslogin = "TRUE"', compute)
        self.assertIn("google_secret_manager_secret", artifacts)
        self.assertNotIn("BEGIN PRIVATE KEY", example)
        self.assertIn("REPLACE_WITH_PRIVATE_DATABASE_PASSWORD", example)
        self.assertNotIn("cloud-platform", compute)


if __name__ == "__main__":
    unittest.main()
