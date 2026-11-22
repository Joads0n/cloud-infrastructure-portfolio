# Workload migration lab — Terraform operations

This root creates a synthetic source/target migration exercise. It does not handle real customer data or automatically migrate a database.

## Prerequisites

- Terraform 1.16.5 and the locked Google provider.
- An existing operator-owned GCP project with Compute, DNS, Storage, IAM, Service Usage, and Network permissions.
- A private variable file based on `terraform.tfvars.example`.
- Synthetic validation data and a defined cutover/rollback time budget.
- A reviewed cost window for two VPCs, a MIG, load balancer, bucket, and logs.

## Local checks

```sh
umask 077
terraform -chdir=workload-migration-case/infra/workload_migration_lab init -lockfile=readonly
terraform -chdir=workload-migration-case/infra/workload_migration_lab fmt -check -recursive
terraform -chdir=workload-migration-case/infra/workload_migration_lab validate
python3 -m unittest discover -s workload-migration-case/tests -v
```

These commands do not create source or target resources. Live cutover and rollback require an approved plan and synthetic data only.

## Private inputs and lifecycle

Copy the example to `.private/maple-migration.tfvars`. Select `active_backend = "source"` for baseline validation. Change it to `target` only in a reviewed plan, record DNS and HTTP observations, and return it to `source` to measure rollback.

```sh
terraform -chdir=workload-migration-case/infra/workload_migration_lab plan \
  -input=false -var-file="$PWD/.private/maple-migration.tfvars" \
  -out="$PWD/.private/maple-migration.tfplan"
terraform -chdir=workload-migration-case/infra/workload_migration_lab apply \
  "$PWD/.private/maple-migration.tfplan"
```

Destroy with the same state and variables after collecting sanitized evidence. Check bucket object versions separately; `force_destroy=false` is intentional so retained artifacts are not silently removed.
