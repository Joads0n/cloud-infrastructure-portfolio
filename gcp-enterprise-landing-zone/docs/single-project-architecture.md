<a id="cedar-route-logistics-basic-project-level-landing-zone"></a>

# Cedar Route Logistics: landing zone básica no nível de projeto

<a id="scenario-and-requirements"></a>

## Cenário e requisitos

A Cedar Route Logistics é fictícia. Seu operador de plataforma precisa de um pequeno ambiente GCP para um serviço web monolítico sem estado, representado por Nginx e HTML sintético. O objetivo é demonstrar reprodutibilidade, acesso restrito, backends redundantes, alterações manuais de capacidade e recuperação básica de discos, sem organização nem plataforma de governança com múltiplos projetos.

O modo padrão de avaliação cria um projeto de produção descartável, vincula uma conta de faturamento existente, aplica labels e habilita APIs. Nossos testes podem usar um projeto existente com `project_settings.create_project=false`; o ciclo de vida desse projeto não é assumido pela configuração. O nome fictício público é `fictional-crl-prod`; os IDs reais permanecem privados. Não há implantação dev nem dependência de projeto de gerenciamento nesses recursos. `prod` é a convenção de nomes/labels, independentemente do sufixo do ID do projeto existente. Esse cenário fictício de produção mantém dimensionamento de laboratório e HTTP temporário; não é uma alegação de prontidão para produção. Permanecem como limites acordados: região `us-central1`, duas réplicas `e2-micro` não Spot com discos de inicialização `pd-standard` de 10 GB e expansão opcional para três réplicas.

<a id="architecture"></a>

## Arquitetura

O desenho e os valores dos controles descrevem a configuração fictícia padrão, não valores de implantação fixos no código. Os [parâmetros de implantação](deployment-inputs.md) permitem variar nomes, localização, CIDR, dimensionamento e snapshots, preservando a topologia. HTTP continua sendo o frontend padrão mediante aceite explícito; o HTTPS opcional termina no mesmo LB global, usando certificados existentes. Ambos utilizam o mesmo backend HTTP privado.

```text
Internet → IPv4 global reservado → Application LB externo (HTTP e/ou HTTPS)
                                      │ HTTP com verificação de integridade
Projeto único de produção / VPC própria / sub-rede 10.80.10.0/24
                     ┌────────────────┴────────────────┐
                 VM privada                       VM privada
               us-central1-a                    us-central1-b
                     └── MIG regional: 2 → 3 → 2 ─────┘
                          │ saída para baixar pacotes
                 Cloud NAT + IPv4 regional reservado

Operador → IAP + OS Login → SSH
Discos de inicialização → política diária de snapshots → armazenamento multirregional US
```

O LB é gerenciado fora da sub-rede das VMs. Os endereços dos backends são dinâmicos e não ficam expostos publicamente. Uma conta de serviço de execução recebe somente os papéis Logs Writer e Monitoring Metric Writer, sem chaves. O operador humano executa Terraform com ADC. Não são introduzidas políticas organizacionais, Shared VPC, centralização de logs, obrigatoriedade de módulos remotos nem dependência do bootstrap legado. A [ADR 0010](decisions/0010-vm-telemetry-and-snapshot-adjustments.md) registra o dispositivo de vídeo, a instalação do Ops Agent na inicialização e a limitação do MIG quanto à proteção contra exclusão.

| Controle | Implementação |
| --- | --- |
| Entrada HTTP dos backends | TCP 80 somente das faixas dos proxies e verificações de integridade do Google |
| Administração | TCP 22 da faixa do IAP; autorização IAM/OS Login separada |
| Saída | TCP 80/443 pelo NAT; demais saídas comuns para a internet negadas |
| Outras entradas | Negação explícita após as permissões restritas |
| Snapshots | Janela diária de início 05:00–06:00 UTC / 02:00–03:00 Fortaleza, retenção de sete dias, `us`, consistência de falha (crash-consistent) |
| Observabilidade | Ops Agent instalado na inicialização; papéis de escrita de logs/métricas; Monitoring API habilitada e mantida |
| Capacidade do LB | Meta UTILIZATION de 0,8; scaling manual, não limite de CPU nem autoscaler |
| Estado de IaC | Local, protegido e ignorado pelo Git; backups independentes; sem bucket ou migração de backend |
| Governança | Nomes, labels, responsabilidade única por recurso, parâmetros privados e orçamento acumulado |
| Ciclo de vida dos discos | Discos de inicialização excluídos automaticamente com as VMs; sem preservação stateful; retenção de snapshots independente |

<a id="validation-and-lifecycle"></a>

## Validação e ciclo de vida

Valide localmente a formatação e o esquema; o responsável executa as suítes de planos simulados e o plano real. A aceitação em execução deve observar ambos os backends, falha/recuperação controladas, scaling, limites do firewall, vínculo dos snapshots aos discos e limpeza. Um exercício de restauração de snapshot é diferente da comprovação da execução agendada. Consulte o [guia operacional](../infra/README.md).

Todo o portfólio permanece limitado a R$ 300. As sessões incluem provisionamento e limpeza em uma hora, com a desmontagem iniciada até o minuto 40. Custos de snapshots e IPs retidos precisam de conciliação explícita; retenção automática não garante exclusão no prazo. Use um único registro financeiro global e uma verificação simples de custos e saldo disponível antes da sessão; não é exigida estimativa detalhada por case. O [registro de evidências](single-project-validation.md) separa a saúde inicial observada, os relatos do responsável sobre implantação/limpeza e os testes de aceitação restantes.

<a id="decisions-and-history"></a>

## Decisões e histórico

A [ADR 0014](decisions/0014-single-architecture-root.md) consolida a implementação em `infra/vm-web-platform/`. A preparação do projeto e os recursos da aplicação compartilham um único diretório raiz e contrato de parâmetros, com arquivos separados por responsabilidade. Os testes Python permanecem em `tests/` no nível do case; os testes Terraform e templates das VMs ficam dentro do diretório Terraform. Os arquivos de seed/bootstrap/controlador são apenas históricos.

A [ADR 0013](decisions/0013-disposable-project-and-resource-files.md) substitui a restrição a projeto existente. Os valores permanecem separados da implementação, e os arquivos são agrupados por responsabilidade. Um apply executado pelo responsável resolve as dependências; o destroy remove os recursos gerenciados e solicita a exclusão do projeto somente quando ele foi criado por esse estado. O fluxo atual mantém o estado local até concluir a limpeza. Configurações antigas de backend exigem revisão separada antes de usar esta versão.

A [ADR 0011](decisions/0011-single-production-project.md) define o escopo exclusivo de produção; a ADR 0009 registra a simplificação anterior. Os resultados anteriores pertencem a dev, e a implantação/validação em produção continuam pendentes. Os arquivos anteriores em `docs/proposals/` preservam apenas o histórico do desenho com múltiplos projetos. O seed já aplicado ao laboratório pessoal não é destruído nem assumido silenciosamente por esta configuração. Seu acesso temporário continua sendo um item separado de manutenção.
