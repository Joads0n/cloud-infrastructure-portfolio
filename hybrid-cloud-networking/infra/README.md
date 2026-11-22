# Hybrid Network Lab — Terraform operations

This root manages the GCP side of a fictional hybrid networking exercise. The peer is an external, simulated on-premises contract. It is not created by this repository.

## Prerequisites

- Terraform 1.16.5 and the locked Google provider.
- An operator-owned GCP project with Compute, Network Connectivity, and Logging permissions.
- A private variable file based on `terraform.tfvars.example`.
- An approved external peer configuration if a real tunnel session is attempted.
- A cost and cleanup window. Do not apply this case with production peer addresses or shared secrets.

## Local checks

```sh
umask 077
terraform -chdir=hybrid-cloud-networking/infra/hybrid_network_lab init -lockfile=readonly
terraform -chdir=hybrid-cloud-networking/infra/hybrid_network_lab fmt -check -recursive
terraform -chdir=hybrid-cloud-networking/infra/hybrid_network_lab validate
python3 -m unittest discover -s hybrid-cloud-networking/tests -v
```

These checks do not create cloud resources. Provider initialization may need network access to the Terraform Registry; validation itself does not authenticate to GCP.

## Private inputs and lifecycle

Copy the example to `.private/orion-hybrid.tfvars`. Replace only the project ID, peer public addresses, BGP values, and shared secret in the private file. The shared secret is sensitive and must not be placed in Git, plans, logs, or screenshots.

Generate and review a plan with the same variables used for apply:

```sh
terraform -chdir=hybrid-cloud-networking/infra/hybrid_network_lab plan \
  -input=false -var-file="$PWD/.private/orion-hybrid.tfvars" \
  -out="$PWD/.private/orion-hybrid.tfplan"
terraform -chdir=hybrid-cloud-networking/infra/hybrid_network_lab apply \
  "$PWD/.private/orion-hybrid.tfplan"
```

Before the planned session ends, remove the resources with the same state and variables:

```sh
terraform -chdir=hybrid-cloud-networking/infra/hybrid_network_lab destroy \
  -var-file="$PWD/.private/orion-hybrid.tfvars"
```

Record tunnel state, BGP routes, failover timing, and cleanup. A successful Terraform apply does not prove that the external peer is configured or that traffic crossed the tunnel.
