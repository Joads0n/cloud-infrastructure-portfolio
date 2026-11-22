# Guia operacional da implementação Terraform — Vértice Network Lab

Este diretório é a raiz Terraform do case **GCP Secure Network Architecture**. Ele implementa uma pasta opcional, dois projetos, duas VPCs, sub-redes segmentadas, VPC Peering, DNS privado, Cloud NAT, políticas de firewall, Cloud NGFW Enterprise com IDS/IPS, VMs privadas, logs e Connectivity Tests.

O case é independente dos demais cases do catálogo. O estado, os projetos, as VPCs e as identidades deste diretório não devem ser compartilhados com outra raiz Terraform.

## Pré-requisitos e limites de segurança

O modo padrão cria dois projetos de workload, vincula uma conta de faturamento existente, aplica labels e habilita as APIs necessárias. Não cria o projeto administrativo/quota, a organização, a pasta ou a conta de faturamento. O projeto administrativo usado por `platform_settings.bootstrap_project_id` e `platform_settings.billing_project_id` precisa existir antes do `terraform plan` e permanecer fora do ciclo de vida desta raiz.

Uma pasta só pode ser criada dentro de uma organização GCP real. A opção **No organization**, exibida com ID `0`, não é uma organização administrável e não pode ser usada como pai de uma pasta. Sem uma organização, use `create_folder=false` e mantenha `organization_id` e `folder_id` vazios. Para usar uma pasta existente, defina `create_folder=false` e informe o identificador `folder_id`.

O modo de projeto existente (`project_settings.create_projects=false`) não cria nem exclui os projetos. Os dois IDs, VPCs e APIs precisam estar autorizados e compatíveis com o cenário; o Terraform gerencia somente os recursos declarados nesta raiz. Não reutilize VPCs, estados ou contas de serviço pertencentes a outro case.

Use ADC do usuário, verifique a identidade efetiva e o projeto de faturamento usado para as APIs. São necessárias permissões para criação de projetos e pasta quando aplicável, faturamento, Service Usage, Compute, DNS, Network Security, Network Management, Logging, Monitoring e IAM. Para o projeto de serviços, o operador precisa de `roles/networksecurity.securityProfileAdmin` para criar o perfil/grupo de segurança, `roles/networksecurity.firewallEndpointAdmin` para criar o endpoint e a associação, e `roles/compute.securityAdmin` para criar as regras das Network Firewall Policies. A associação da política à VPC requer `roles/compute.networkAdmin` ou permissão equivalente. `roles/compute.networkAdmin` também cobre as operações do NGFW, mas concede um escopo mais amplo. A Network Security API e a Certificate Authority Service API precisam estar habilitadas no projeto alvo. Não conceda `Owner` automaticamente para contornar uma permissão ausente.

### Projeto administrativo, APIs e permissões antes do plano

O projeto informado em `bootstrap_project_id` é usado como projeto de quota e para as operações administrativas do provider. Ele deve ser um projeto existente, ativo e acessível pela identidade que executa o Terraform. Para este case, o exemplo usa o identificador fictício `prj-vertice-network-admin`; substitua-o no arquivo privado se o seu projeto administrativo tiver outro ID. A raiz não cria nem exclui esse projeto.

Antes do primeiro plano, habilite as APIs de pré-requisito nesse projeto:

```sh
gcloud config set project <BOOTSTRAP_PROJECT_ID>
gcloud services enable \
  cloudbilling.googleapis.com \
  cloudresourcemanager.googleapis.com \
  serviceusage.googleapis.com \
  --project=<BOOTSTRAP_PROJECT_ID>
```

`cloudbilling.googleapis.com` é necessária para a validação da conta de faturamento realizada pelo provider. A ativação pode levar alguns minutos para propagar. A identidade precisa da permissão `serviceusage.services.enable`, normalmente incluída em `roles/serviceusage.serviceUsageAdmin` no projeto administrativo.

| Escopo | Permissão ou função mínima | Finalidade |
|---|---|---|
| Projeto administrativo | `serviceusage.services.enable` (`roles/serviceusage.serviceUsageAdmin`) | Habilitar e consultar as APIs de pré-requisito e usar o projeto de quota |
| Conta de faturamento | `billing.resourceAssociations.create` (`roles/billing.user`) | Vincular os dois projetos novos à conta informada |
| Criação de projetos | `resourcemanager.projects.create` (`roles/resourcemanager.projectCreator`, quando houver organização ou pasta) | Criar `apps_project_id` e `services_project_id` |
| Criação de pasta | `resourcemanager.folders.create` (`roles/resourcemanager.folderCreator` ou `roles/resourcemanager.folderAdmin`) | Criar a pasta somente quando houver organização real |
| Projeto de serviços | `roles/networksecurity.securityProfileAdmin`, `roles/networksecurity.firewallEndpointAdmin` | Criar perfil, grupo, endpoint e associação do NGFW |
| Projetos de workload | `roles/compute.securityAdmin` e `roles/compute.networkAdmin`, ou permissões equivalentes | Criar políticas, regras e associações de rede |

O Terraform habilita nos projetos de workload as APIs de Compute, DNS, IAM, IAP, Logging, Monitoring, Network Management, Network Security, OS Login, Service Usage e Certificate Authority Service. A lista é declarada em `locals.tf`; a Cloud Billing API do projeto administrativo deve ser habilitada previamente, pois a checagem do faturamento acontece antes de esses projetos existirem. O OS Login é ativado nas três VMs, mas as autorizações do operador (`roles/compute.osLogin`, `roles/iap.tunnelResourceAccessor` e `roles/iam.serviceAccountUser`) permanecem fora desta raiz.

Quando a conta não possui uma organização, os projetos novos ficam no nível superior **No organization**. Nesse caso, não informe `organization_id = "0"`; use `create_folder=false`.

O Cloud NGFW Enterprise é requisito obrigatório. O endpoint, o perfil `THREAT_PREVENTION`, o grupo de perfil e a associação podem gerar cobrança por recurso e tráfego. Confirme organização, cotas, disponibilidade regional e saldo antes de iniciar.

## Versões das ferramentas e estado

Versões fixadas: Terraform 1.16.5, providers `google` e `google-beta` 8.5.0. O backend é exclusivamente local; não há bucket, migração ou backend remoto neste case. O lock file deve ser mantido no Git.

Na raiz do repositório, valide a configuração com:

```sh
umask 077
terraform -chdir=gcp-secure-network-architecture/infra/secure_network_lab init -lockfile=readonly
terraform -chdir=gcp-secure-network-architecture/infra/secure_network_lab fmt -check -recursive
terraform -chdir=gcp-secure-network-architecture/infra/secure_network_lab validate
```

Esses comandos não executam plano nem acessam recursos gerenciados. Preserve o estado local com permissões restritas, cópias protegidas e armazenamento criptografado. Git ignore não é backup. Não execute duas instâncias do Terraform simultaneamente.

## Parâmetros privados

Use [`terraform.tfvars.example`](secure_network_lab/terraform.tfvars.example) como modelo. Copie-o para `.private/vertice-network.tfvars` na raiz do repositório e substitua, de forma privada, os IDs dos projetos, o billing account, a organização ou pasta e demais valores autorizados. O arquivo privado, o estado e os planos não devem ser versionados.

Os sete objetos de entrada organizam plataforma, hierarquia, projetos, rede, computação, NGFW e testes. Os CIDRs precisam ser privados e não sobrepostos. Os nomes do exemplo são fictícios; não publique IDs reais, credenciais, endereços de endpoints ou saídas de testes contendo dados sensíveis.

Para projeto novo, mantenha `create_projects=true`, informe `billing_account_id` e use uma hierarquia autorizada. Para projetos existentes, defina `create_projects=false` e deixe `billing_account_id` vazio; nunca altere os IDs ou o modo de ciclo de vida em um estado que já gerencie recursos.

### Objetos de entrada por responsabilidade

| Objeto | Responsabilidade | Exemplos de valores |
|---|---|---|
| `platform_settings` | Projeto administrativo/quota, faturamento da API, região, zonas e labels comuns | `bootstrap_project_id`, `billing_project_id`, `us-central1` |
| `organization_settings` | Pasta opcional e vínculo à organização | `organization_id`, `folder_id`, `create_folder` |
| `project_settings` | IDs, nomes, billing e labels específicos dos dois projetos do laboratório | projeto de aplicações e projeto de serviços |
| `network_settings` | VPCs, sub-redes, CIDRs e DNS privado | CIDRs RFC 1918 sem sobreposição e registro dentro da zona |
| `compute_settings` | Imagem, tipo, nomes das VMs e disco de inicialização | Debian, `f1-micro`, 10 GB |
| `ngfw_settings` | Endpoint, perfil, grupo de perfil e logging do Cloud NGFW | `THREAT_PREVENTION`, zona do endpoint |
| `test_settings` | Ativação dos Connectivity Tests e porta avaliada | caminhos permitido/bloqueado, TCP 80 |

`platform_settings.bootstrap_project_id` e `billing_project_id` devem apontar para um projeto existente e autorizado para as operações administrativas e de quota. Eles não são criados nem excluídos por esta raiz. Os labels comuns e específicos são combinados nos projetos criados; a chave `role` identifica aplicações e serviços internos.

## Plano e implantação executados pelo responsável

Antes do plano, confirme credenciais, cotas, hierarquia, permissões, APIs, custos do NGFW, conflitos de nomes e janela de limpeza. Gere o plano na raiz do repositório:

```sh
umask 077
terraform -chdir=gcp-secure-network-architecture/infra/secure_network_lab init -lockfile=readonly
terraform -chdir=gcp-secure-network-architecture/infra/secure_network_lab plan \
  -input=false -lock-timeout=60s \
  -var-file="$PWD/.private/vertice-network.tfvars" \
  -out="$PWD/.private/vertice-network-reviewed.tfplan"
```

Revise o plano antes do apply. A ordem lógica esperada é:

1. Pasta e projetos, quando habilitados.
2. APIs, contas de serviço, VPCs, sub-redes, peering, NAT e DNS.
3. Perfil, grupo, endpoint e associação do Cloud NGFW.
4. Políticas de firewall, VMs, serviço HTTP fictício e Connectivity Tests.

Os nomes dos arquivos não definem a ordem; o Terraform segue dependências. Todos os planos, applies e destroys são executados pelo responsável. Não reutilize planos produzidos para outro arquivo de variáveis ou outro projeto.

## Validação prevista

Execute os testes Python estáticos antes de qualquer sessão no GCP:

```sh
python3 -m unittest discover -s gcp-secure-network-architecture/tests -v
```

Depois do apply, valide a matriz de comunicação documentada no README do case:

1. A VM da aplicação resolve `orders.internal.vertice.example.` e acessa o serviço por HTTP privado.
2. A VM de testes não acessa o serviço de pedidos/estoque.
3. O Connectivity Test do caminho permitido e o do caminho bloqueado apresentam resultados coerentes com as políticas.
4. Os logs de firewall, Flow Logs e registros do NGFW correlacionam origem, destino, porta e decisão. O Flow Logs usa amostragem reduzida para manter o laboratório de baixo custo.
5. O teste de IDS/IPS usa tráfego seguro e reproduzível em um caminho permitido; um bloqueio anterior ao endpoint não comprova inspeção.
6. As VMs permanecem sem IP público e a administração ocorre por IAP/OS Login, depois que as autorizações do operador forem concedidas.

Provisionar o endpoint não comprova detecção ou prevenção. Não use malware real. As evidências públicas devem ser sanitizadas e não devem conter credenciais, IDs reais ou endpoints ativos.

## Custos e limpeza

O limite permanece **R$ 300 acumulados para todo o portfólio**, e cada sessão deve caber em **uma hora**, incluindo provisionamento e limpeza. O cálculo inclui NGFW Enterprise, processamento de tráfego, NAT, VMs/discos, logs, Connectivity Tests e artefatos retidos. As políticas permitem somente TCP 80/443 e DNS UDP/53 para saída externa; o restante é negado. Não presuma gratuidade.

Comece a contagem antes do apply e inicie a desmontagem até o minuto 40 ou antes. Use os mesmos parâmetros e o mesmo estado local:

```sh
terraform -chdir=gcp-secure-network-architecture/infra/secure_network_lab apply \
  "$PWD/.private/vertice-network-reviewed.tfplan"

terraform -chdir=gcp-secure-network-architecture/infra/secure_network_lab destroy \
  -var-file="$PWD/.private/vertice-network.tfvars"
```

O destroy mantém confirmação interativa; não use `-auto-approve` sem decisão explícita. No modo de projetos novos, confirme a remoção das VMs, discos, VPCs, peering, NAT, DNS, políticas, endpoint e associações antes de confirmar a solicitação de exclusão dos projetos. No modo existente, o destroy não pode remover os projetos nem recursos alheios ao estado.

Revise endpoints, perfis, logs, Connectivity Tests e possíveis cobranças atrasadas após a limpeza. O estado Terraform não inventaria snapshots ou artefatos fora dele; qualquer recurso retido precisa de conferência separada.

## Ciclo de vida do projeto e fluxo do avaliador

O fluxo normal usa uma única raiz Terraform, um arquivo privado de parâmetros, estado local e um operador. Não é necessário executar seed, bootstrap ou outra raiz do catálogo.

1. Autentique-se com ADC do usuário e confirme permissões para Resource Manager, faturamento, Service Usage, Compute, DNS, Network Security, Network Management, Logging, Monitoring e IAM. A organização, a pasta usada e o projeto administrativo/quota já devem existir.
2. Escolha explicitamente o modo no arquivo privado: `create_projects=true` para criar os dois projetos descartáveis, ou `create_projects=false` para usar projetos já existentes. No primeiro modo, informe `billing_account_id`; no segundo, deixe-o vazio. Não altere o modo nem os IDs em um estado já utilizado.
3. Execute `init`, `fmt`, `validate` e os testes Python estáticos. Gere um plano revisado com o mesmo arquivo de variáveis que será usado no apply.
4. Aplique somente o plano aprovado. O Terraform cria, quando habilitado, a pasta e os projetos; depois habilita APIs, cria redes, peering, NAT, DNS, políticas, inspeção, VMs e Connectivity Tests conforme as dependências.
5. Registre as saídas, execute os testes de conectividade permitidos e bloqueados e recolha evidências sanitizadas. A validação declarativa não substitui tráfego real nem demonstra IDS/IPS por si só.
6. Destrua o laboratório com os mesmos parâmetros e o mesmo estado antes do fim da janela de custo. No modo de projetos novos, a exclusão dos projetos é solicitada pela política `DELETE`; no modo existente, somente os recursos deste estado são removidos.

Nenhum plano, apply ou destroy é automático neste case. O avaliador permanece responsável por revisar custos, permissões, plano, evidências e limpeza.

## Limitações conhecidas

- A pasta só pode ser criada dentro de uma organização existente; o case não cria a organização.
- O endpoint configurado em uma zona não representa automaticamente uma implantação regional de alta disponibilidade.
- O cenário usa VMs pequenas e um serviço HTTP fictício; não é uma plataforma de comércio eletrônico nem um teste de capacidade.
- Connectivity Tests são análise declarativa de configuração; não substituem requisições reais.
- Regras de firewall, NAT e DNS não comprovam sozinhas o funcionamento do IDS/IPS.
- Não há HA VPN, BGP, Shared VPC ou VPC Service Controls neste case.
- O teste de NGFW não garante proteção contra todas as ameaças.

## Mapa dos arquivos

```text
gcp-secure-network-architecture/
  infra/
    README.md                         # Este guia operacional
    secure_network_lab/               # Raiz Terraform ativa
      terraform.tfvars.example        # Valores fictícios para o avaliador
      versions.tf, providers.tf       # Terraform e providers fixados
      variables.tf, locals.tf         # Contrato e valores derivados
      organization.tf, apis.tf        # Pasta, projetos e APIs
      network.tf, nat.tf, dns.tf      # VPCs, sub-redes, peering, NAT e DNS
      firewall_policies.tf             # Políticas e regras de tráfego
      ngfw.tf                          # Perfil, endpoint e associação NGFW
      compute.tf, service_accounts.tf # VMs e identidades de runtime
      connectivity_tests.tf            # Testes declarativos de conectividade
      outputs.tf                       # IDs, IP e nome DNS privado
      templates/                       # Script de inicialização do fixture
      .terraform.lock.hcl              # Lock dos providers
  tests/                               # Testes Python estáticos do case
```

O Terraform carrega todos os arquivos `.tf` da raiz em conjunto e segue dependências. Os nomes seguem `snake_case`; a separação por arquivo facilita revisão, mas não cria módulos ou estados independentes.
