"""Verificações locais de renderização; sem navegador, plano Terraform ou chamadas à nuvem."""
from pathlib import Path
import unittest

MODULE = Path(__file__).resolve().parents[1] / "infra/vm-web-platform/templates"


class BackendPageTests(unittest.TestCase):
    def test_distinct_replicas_have_visible_identity(self):
        source = (MODULE / "index.html.tftpl").read_text()
        pages = []
        for token in ("abcdef12-345", "123456ab-cde", "fedcba98-765"):
            page = source.replace("${environment}", "prod").replace("__BACKEND_TOKEN__", token).replace("__BACKEND_COLOR__", token[:6])
            self.assertIn(f"BACKEND {token}</strong>", page)
            self.assertIn(f"#{token[:6]}", page)
            self.assertNotIn("__BACKEND_", page)
            pages.append(page)
        self.assertEqual(len(set(pages)), 3)

    def test_server_identity_and_no_cache_are_preserved(self):
        script = (MODULE / "startup.sh.tftpl").read_text()
        self.assertIn('if [ ! -s /var/lib/crl/backend-token ]; then', script)
        self.assertIn('add_header X-Lab-Backend "$backend_token" always;', script)
        self.assertIn('add_header Cache-Control "no-store" always;', script)
        self.assertIn('s/__BACKEND_COLOR__/$backend_color/g', script)


if __name__ == "__main__":
    unittest.main()
