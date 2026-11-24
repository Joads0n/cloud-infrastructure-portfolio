# Testes do case

Os testes verificam o contrato estático da arquitetura AWS → GCP. Eles não acessam AWS, não criam recursos e não validam a saúde real do Load Balancer.

```sh
python3 -m unittest discover -s workload-migration-case/tests -v
```

A validação Terraform deve ser executada separadamente:

```sh
terraform -chdir=workload-migration-case/infra/workload_migration_lab fmt -check -recursive
terraform -chdir=workload-migration-case/infra/workload_migration_lab validate
```
