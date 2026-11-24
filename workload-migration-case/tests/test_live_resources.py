"""Validação operacional opcional dos recursos GCP após plan/apply."""

import json
import os
from pathlib import Path
import subprocess
import unittest
from urllib.parse import urlparse


CASE = Path(__file__).resolve().parents[1]
ROOT = CASE / "infra" / "workload_migration_lab"
PHASES = {"pre-migration", "post-migration"}


def _run(command):
    result = subprocess.run(command, check=True, capture_output=True, text=True)
    return result.stdout.strip()


def _json_command(command):
    output = _run(command)
    return json.loads(output) if output else None


class LiveResourceTests(unittest.TestCase):
    """Testes explícitos para o ambiente criado pelo avaliador."""

    @classmethod
    def setUpClass(cls):
        if os.getenv("RUN_LIVE_TESTS") != "1":
            raise unittest.SkipTest("Defina RUN_LIVE_TESTS=1 para acessar o GCP real.")

        cls.phase = os.getenv("MIGRATION_PHASE", "pre-migration")
        if cls.phase not in PHASES:
            raise AssertionError(f"MIGRATION_PHASE deve ser uma destas opções: {sorted(PHASES)}")

        cls.outputs = _json_command([
            "terraform",
            f"-chdir={ROOT}",
            "output",
            "-json",
        ])
        if not cls.outputs:
            raise AssertionError("O estado Terraform não possui outputs; execute o apply antes dos testes live.")

        cls.values = {name: value["value"] for name, value in cls.outputs.items()}
        cls.project = cls.values["destination_project_id"]
        cls.region = cls.values["region"]
        cls.zone = cls.values["zone"]

    def gcloud(self, *args):
        return _json_command(["gcloud", *args, "--format=json"])

    def test_project_and_required_apis_exist(self):
        project = self.gcloud("projects", "describe", self.project)
        self.assertEqual(project["projectId"], self.project)
        self.assertEqual(project["lifecycleState"], "ACTIVE")

        services = self.gcloud("services", "list", "--enabled", f"--project={self.project}")
        enabled = {item["config"]["name"] for item in services}
        required = {
            "cloudresourcemanager.googleapis.com",
            "compute.googleapis.com",
            "dns.googleapis.com",
            "iam.googleapis.com",
            "logging.googleapis.com",
            "monitoring.googleapis.com",
            "servicecontrol.googleapis.com",
            "servicemanagement.googleapis.com",
            "serviceusage.googleapis.com",
            "vmmigration.googleapis.com",
        }
        self.assertTrue(required.issubset(enabled))

    def test_private_network_router_and_nat_exist(self):
        network = self.gcloud(
            "compute", "networks", "describe", self.values["network_name"],
            f"--project={self.project}",
        )
        self.assertFalse(network["autoCreateSubnetworks"])
        self.assertEqual(network["routingConfig"]["routingMode"], "REGIONAL")

        subnet = self.gcloud(
            "compute", "networks", "subnets", "describe", self.values["subnet_name"],
            f"--region={self.region}", f"--project={self.project}",
        )
        self.assertTrue(subnet["privateIpGoogleAccess"])

        routers = self.gcloud(
            "compute", "routers", "nats", "list",
            f"--router={self.values['router_name']}",
            f"--region={self.region}", f"--project={self.project}",
        )
        self.assertIn(self.values["nat_name"], {item["name"] for item in routers})

    def test_firewall_controls_are_restricted(self):
        health = self.gcloud(
            "compute", "firewall-rules", "describe",
            self.values["health_firewall_name"],
            f"--project={self.project}",
        )
        self.assertEqual(set(health["sourceRanges"]), {"35.191.0.0/16", "130.211.0.0/22"})
        self.assertEqual(health["allowed"][0]["IPProtocol"], "tcp")
        self.assertIn("80", health["allowed"][0]["ports"])

        iap = self.gcloud(
            "compute", "firewall-rules", "describe",
            self.values["iap_firewall_name"],
            f"--project={self.project}",
        )
        self.assertEqual(iap["sourceRanges"], ["35.235.240.0/20"])
        self.assertIn("22", iap["allowed"][0]["ports"])

    def test_global_application_load_balancer_exists(self):
        address = self.gcloud(
            "compute", "addresses", "describe", self.values["global_load_balancer_name"],
            "--global", f"--project={self.project}",
        )
        self.assertEqual(address["addressType"], "EXTERNAL")
        self.assertEqual(address["address"], self.values["global_load_balancer_ip"])

        backend = self.gcloud(
            "compute", "backend-services", "describe", self.values["backend_service_name"],
            "--global", f"--project={self.project}",
        )
        self.assertEqual(backend["loadBalancingScheme"], "EXTERNAL_MANAGED")
        self.assertEqual(backend["protocol"], "HTTP")
        self.assertTrue(any(self.values["instance_group_name"] in item["group"] for item in backend["backends"]))

        self.gcloud(
            "compute", "health-checks", "describe", self.values["health_check_name"],
            f"--project={self.project}",
        )

    def test_migrated_backend_count_matches_phase(self):
        instances = self.gcloud(
            "compute", "instance-groups", "unmanaged", "list-instances",
            self.values["instance_group_name"], f"--zone={self.zone}", f"--project={self.project}",
        )
        expected_count = 0 if self.phase == "pre-migration" else 2
        self.assertEqual(len(instances), expected_count)

        links = self.values["target_instance_self_links"]
        self.assertEqual(len(links), expected_count)
        if self.phase == "post-migration":
            health = self.gcloud(
                "compute", "backend-services", "get-health", self.values["backend_service_name"],
                "--global", f"--project={self.project}",
            )
            states = [item["healthState"] for item in health["healthStatus"]]
            self.assertEqual(states.count("HEALTHY"), 2)

    def test_migrated_vms_have_no_public_ip(self):
        if self.phase == "pre-migration":
            self.skipTest("As VMs ainda não foram criadas pelo M2VM.")

        for link in self.values["target_instance_self_links"]:
            parsed = urlparse(link)
            name = parsed.path.rstrip("/").split("/")[-1]
            zone = parsed.path.split("/zones/")[1].split("/")[0]
            instance = self.gcloud(
                "compute", "instances", "describe", name,
                f"--zone={zone}", f"--project={self.project}",
            )
            interfaces = instance.get("networkInterfaces", [])
            self.assertTrue(interfaces)
            self.assertTrue(all("accessConfigs" not in interface for interface in interfaces))

    def test_dns_points_to_selected_backend(self):
        records = self.gcloud(
            "dns", "record-sets", "list", "--zone", self.values["dns_zone_name"],
            f"--project={self.project}", "--name", self.values["cutover_record"],
        )
        self.assertEqual(len(records), 1)
        self.assertEqual(records[0]["type"], "A")
        self.assertEqual(records[0]["rrdatas"], [self.values["active_backend_ip"]])

    def test_load_balancer_http_when_requested(self):
        if os.getenv("VALIDATE_LB_HTTP") != "1":
            self.skipTest("Defina VALIDATE_LB_HTTP=1 para executar o smoke test HTTP.")
        if self.phase != "post-migration":
            self.skipTest("O smoke test HTTP exige a fase pós-migração.")

        response = subprocess.run(
            ["curl", "--fail", "--silent", "--show-error", "--max-time", "15", f"http://{self.values['global_load_balancer_ip']}/"],
            check=True,
            capture_output=True,
            text=True,
        )
        self.assertTrue(response.stdout.strip())


if __name__ == "__main__":
    unittest.main()
