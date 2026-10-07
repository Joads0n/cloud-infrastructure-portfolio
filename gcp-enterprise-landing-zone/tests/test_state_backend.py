"""Contratos estáticos de segurança do backend; sem execução Terraform nem chamadas à nuvem."""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1] / "infra/vm-web-platform"


class StateBackendTests(unittest.TestCase):
    def test_lifecycle_has_only_local_backend(self):
        blocks = []
        for path in ROOT.glob("*.tf"):
            blocks.extend(re.findall(r'^\s*backend\s+"([^"]+)"\s*\{', path.read_text(), re.MULTILINE))
        self.assertEqual(blocks, ["local"])
        self.assertFalse((ROOT / "backend.tf.example").exists())
        self.assertFalse((ROOT / "state.tfbackend.example").exists())

    def test_no_remote_state_infrastructure(self):
        source = "\n".join(p.read_text() for p in ROOT.glob("*.tf"))
        self.assertNotIn("google_storage_bucket", source)
        self.assertNotIn('output "state_bucket_name"', source)
        self.assertNotIn('"storage.googleapis.com"', source)
        self.assertFalse((ROOT / "state-bucket.tf").exists())


if __name__ == "__main__":
    unittest.main()
