# Testes do case

Os testes verificam o contrato estático da arquitetura AWS → GCP. Eles confirmam que:

- o provider é somente Google Cloud e cria o projeto de destino sem projeto bootstrap;
- a origem é representada por exatamente duas VMs AWS existentes, atrás de Load Balancer e NAT egress;
- o M2VM é habilitado e recebe somente metadados não sensíveis da origem;
- o Terraform não provisiona VMs de destino e aceita zero self-links antes da migração ou exatamente dois depois dela;
- a rede privada, Cloud NAT, firewall e Global external Application Load Balancer estão declarados;
- o DNS possui controles explícitos de cutover AWS → GCP e rollback GCP → AWS.

Eles não acessam AWS, não criam recursos e não validam a saúde real do Load Balancer. A validação live deve ocorrer após o `plan/apply`, com evidências do projeto criado, dos dois backends migrados, dos health checks, do egress e do cutover.

```sh
python3 -m unittest discover -s workload-migration-case/tests -v
```

A validação Terraform deve ser executada separadamente:

```sh
terraform -chdir=workload-migration-case/infra/workload_migration_lab fmt -check -recursive
terraform -chdir=workload-migration-case/infra/workload_migration_lab validate
```

## Validação dos recursos no GCP

Depois do `apply`, os testes operacionais usam os outputs do estado Terraform e comandos somente de leitura do `gcloud`. Eles não executam `plan`, `apply` ou `destroy`.

Antes da migração, valide o ambiente preparado e o backend vazio:

```sh
RUN_LIVE_TESTS=1 MIGRATION_PHASE=pre-migration \
  python3 -m unittest workload-migration-case/tests/test_live_resources.py -v
```

Depois que o M2VM criar as duas VMs, atualizar `target_instance_self_links` e aplicar o backend, valide a fase pós-migração:

```sh
RUN_LIVE_TESTS=1 MIGRATION_PHASE=post-migration VALIDATE_LB_HTTP=1 \
  python3 -m unittest workload-migration-case/tests/test_live_resources.py -v
```

Os testes live verificam projeto ativo, APIs, VPC, subnet privada, Cloud NAT, firewalls, IP/LB global, backend service, grupo não gerenciado, quantidade e saúde dos backends, ausência de IP público nas VMs, DNS de cutover e resposta HTTP opcional. Eles não registram a origem AWS nem executam operações M2VM.
