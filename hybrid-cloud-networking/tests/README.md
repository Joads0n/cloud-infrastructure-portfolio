# Hybrid networking tests

Run from the repository root:

```sh
python3 -m unittest discover -s hybrid-cloud-networking/tests -v
terraform -chdir=hybrid-cloud-networking/infra/hybrid_network_lab fmt -check -recursive
terraform -chdir=hybrid-cloud-networking/infra/hybrid_network_lab validate
```

The Python tests inspect the Terraform contract only. They do not authenticate, create VPN tunnels, establish BGP, or send traffic. Live evidence requires a separate operator-approved session with a simulated peer and sanitized route/tunnel outputs.
