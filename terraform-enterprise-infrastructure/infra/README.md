# Terraform Enterprise platform foundation — operations

This root implements a fictional, private platform foundation. It does not install the Terraform Enterprise product or manage its license.

## Prerequisites

- Terraform 1.16.5 and the locked Google provider.
- An existing operator-owned GCP project and billing/quota access.
- Permissions for Compute, Service Usage, Cloud SQL, Service Networking, KMS, Secret Manager, Storage, Logging, Monitoring, and IAM.
- A private variable file with a database password and project ID.
- A reviewed cost window; Cloud SQL, NAT, KMS, and storage can incur charges.

## Local checks

```sh
umask 077
terraform -chdir=terraform-enterprise-infrastructure/infra/terraform_enterprise_lab init -lockfile=readonly
terraform -chdir=terraform-enterprise-infrastructure/infra/terraform_enterprise_lab fmt -check -recursive
terraform -chdir=terraform-enterprise-infrastructure/infra/terraform_enterprise_lab validate
python3 -m unittest discover -s terraform-enterprise-infrastructure/tests -v
```

No command above creates resources. Provider plugin startup may require the sandbox exception used by this workspace; no GCP apply is implied.

## Private inputs and lifecycle

Copy `terraform.tfvars.example` to `.private/cedar-tfe.tfvars`. Replace the project ID and database password privately. Do not add a Secret Manager version through this public root unless the value is supplied through a protected workflow and its state exposure is accepted.

Review a plan before apply:

```sh
terraform -chdir=terraform-enterprise-infrastructure/infra/terraform_enterprise_lab plan \
  -input=false -var-file="$PWD/.private/cedar-tfe.tfvars" \
  -out="$PWD/.private/cedar-tfe.tfplan"
terraform -chdir=terraform-enterprise-infrastructure/infra/terraform_enterprise_lab apply \
  "$PWD/.private/cedar-tfe.tfplan"
```

Destroy with the same state and variables after validation. Confirm that the SQL instance, NAT, KMS key, secret, bucket, and retained objects are handled intentionally before closing the session.
