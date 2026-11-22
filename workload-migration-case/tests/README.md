# Workload migration tests

Run from the repository root:

```sh
python3 -m unittest discover -s workload-migration-case/tests -v
terraform -chdir=workload-migration-case/infra/workload_migration_lab fmt -check -recursive
terraform -chdir=workload-migration-case/infra/workload_migration_lab validate
```

The Python tests inspect the migration contract only. They do not create a source VM, target MIG, load balancer, DNS record, bucket, or cutover. Live validation must use synthetic data and timestamped evidence.
