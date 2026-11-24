# Laboratório Terraform — migração de VMs AWS para GCP

Este root provisiona somente o lado GCP de uma migração de duas VMs. A origem AWS, o ALB AWS, o NAT Gateway AWS e as VMs AWS são fictícios neste exercício e não são gerenciados pelo Terraform.

## Pré-requisitos

- Terraform 1.16.5 e o provider Google bloqueado em `8.5.0`.
- `gcloud auth application-default login` concluído.
- Projeto GCP criado manualmente pelo avaliador, com billing, hierarquia, labels e permissões já configurados.
- Uma conta AWS real somente para a fase de registro e replicação do M2VM; ela não é necessária para os testes estáticos ou para preparar o destino GCP.

## Verificações locais

```sh
terraform -chdir=workload-migration-case/infra/workload_migration_lab init -lockfile=readonly
terraform -chdir=workload-migration-case/infra/workload_migration_lab fmt -check -recursive
terraform -chdir=workload-migration-case/infra/workload_migration_lab validate
python3 -m unittest discover -s workload-migration-case/tests -v
```

Esses comandos não criam recursos. O `plan` também não deve receber access keys AWS; o contrato M2VM usa somente metadados fictícios.

## Preparação do arquivo privado

```sh
umask 077
mkdir -p .private
cp workload-migration-case/infra/workload_migration_lab/terraform.tfvars.example .private/maple-m2vm.tfvars
```

Edite o arquivo privado e informe o `project_id` criado pelo avaliador. O Terraform não cria projeto bootstrap nem projeto de destino. Revise também `environment`, `resource_prefix`, `region` e `zone`; a zona deve pertencer à região. Mantenha `target_instance_self_links = []` até o M2VM criar as duas VMs GCP.

## Plan e apply do lado GCP

```sh
terraform -chdir=workload-migration-case/infra/workload_migration_lab plan \
  -input=false \
  -var-file="$PWD/.private/maple-m2vm.tfvars" \
  -out="$PWD/.private/maple-m2vm.tfplan"

terraform -chdir=workload-migration-case/infra/workload_migration_lab apply \
  "$PWD/.private/maple-m2vm.tfplan"
```

O primeiro apply cria o destino GCP e o Load Balancer sem backends. Depois da criação das duas VMs pelo M2VM, informe seus self-links no arquivo privado, execute novo `plan/apply` e valide os health checks.

## Cutover e rollback

Para cutover, altere `active_backend = "gcp"`, gere um novo plan e aplique após a aprovação. Para rollback, altere para `active_backend = "aws"`. O registro DNS aponta para o VIP GCP ou para o VIP AWS fictício `198.51.100.20`.

O M2VM exige uma origem AWS real e credenciais adequadas no momento do cadastro. Elas devem ser fornecidas somente pelo fluxo oficial do serviço, de preferência com credenciais temporárias, e nunca em `.tfvars`, estado Terraform ou Git.

## Descomissionamento

Após coletar evidências, remova primeiro o registro DNS, o Load Balancer e os demais recursos GCP com o mesmo estado Terraform. Revise operações e VMs do M2VM separadamente. A destruição do projeto pode ser usada somente quando o projeto tiver sido criado por este case e a retenção de evidências tiver terminado.
