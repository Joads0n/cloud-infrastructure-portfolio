<a id="gcp-enterprise-landing-zone"></a>

# Landing Zone corporativa no GCP

Uma landing zone básica, no nível de projeto, para a **Cedar Route Logistics**, empresa fictícia que hospeda um pequeno serviço monolítico sem estado. O Nginx e uma página HTML estática representam a aplicação; este é um case de engenharia de infraestrutura, não um portfólio de desenvolvimento de software.

**Situação:** por padrão, a configuração cria um projeto de produção descartável, com um modo explícito de teste em projeto existente, conforme a [ADR 0013](docs/decisions/0013-disposable-project-and-resource-files.md). A revisão atual sem bucket ainda exige um plano novo. Na implantação anterior, o responsável confirmou apply e acesso à página; posteriormente confirmou a exclusão do projeto. A recuperação local do estado foi concluída, conforme o registro de evidências. No teste anterior em dev, o responsável confirmou o funcionamento da aplicação, da telemetria, da distribuição de tráfego, do scaling, da recuperação após falha, da criação/restauração de snapshots e da limpeza. Essas categorias estão marcadas com ✓ na [lista de testes](docs/single-project-validation.md#owner-confirmed-test-checklist), sem novos artefatos técnicos anexados. As observações diretas do assistente se limitam às duas VMs inicialmente em estado RUNNING e aos dois backends HEALTHY; o responsável forneceu um resumo final de 23 recursos destruídos. A conciliação do faturamento e a comprovação da execução diária dos snapshots continuam pendentes. O seed histórico permanece separado.

<a id="scope-and-evidence"></a>

## Escopo e evidências

Após a conclusão do `terraform apply`, aguarde aproximadamente **2 a 5 minutos** antes de testar a página pelo IP do LB (`lb_ip`). Esse intervalo é uma estimativa, não uma garantia: as VMs ainda podem estar executando o script de inicialização e instalando o Nginx, enquanto o balanceador verifica a saúde dos backends. O sucesso do apply não significa que a página já esteja disponível. Se a espera se prolongar, confira os backends e os logs de inicialização conforme o [guia operacional](infra/README.md#planned-runtime-checks). A espera conta dentro do limite de uma hora da sessão.

O laboratório usa estado Terraform local durante todo o ciclo de vida. Não cria bucket nem exige migração de backend. Preserve o arquivo de estado e backups privados até concluir a limpeza; não os publique no Git. A [ADR 0018](docs/decisions/0018-local-state-only.md) registra a simplificação.

Os valores da implantação são configuráveis separadamente da implementação dos recursos: consulte o [guia de parâmetros](docs/deployment-inputs.md), o [exemplo completo de tfvars](infra/vm-web-platform/terraform.tfvars.example) e a [ADR 0012](docs/decisions/0012-configurable-deployment-values.md). A arquitetura abaixo descreve a configuração fictícia padrão. O HTTPS opcional referencia certificados existentes; valores personalizados e HTTPS ainda não possuem evidências de validação em nuvem.

Ajustes recentes de configuração: a [ADR 0010](docs/decisions/0010-vm-telemetry-and-snapshot-adjustments.md) acrescenta dispositivo de vídeo virtual, instalação do Ops Agent na inicialização com papéis de escrita de telemetria, utilização-alvo de 80% no LB, snapshots multirregionais US com início entre 02:00 e 03:00 no horário de Fortaleza e exibição de `lb_ip`. O MIG não oferece proteção contra exclusão por VM. Em dev, o responsável relatou a aplicação da implantação revisada, seguida da alteração da retenção para sete dias e da destruição dos recursos. A verificação independente do agente e da execução dos snapshots continua pendente.

- [Cenário, arquitetura e requisitos atuais](docs/single-project-architecture.md)
- [Execução, validação, custos e limpeza](infra/README.md)
- [Diretório Terraform único da arquitetura](infra/vm-web-platform/README.md): preparação do projeto e implementação dos recursos no mesmo lugar
- [Rede e snapshots](docs/decisions/0008-network-backups-and-module-selection.md), com a preferência por módulos substituída pela [ADR 0009](docs/decisions/0009-single-project-owner-operated-lab.md)
- [Testes, cobertura e resultados esperados](tests/README.md)
- [Validação da reestruturação e verificações pendentes](docs/single-project-validation.md)

O fluxo padrão cria um projeto de produção, vincula uma conta de faturamento existente, aplica labels e habilita APIs antes de provisionar uma VPC e uma sub-rede próprias, um Application Load Balancer global externo HTTP com IP reservado, duas VMs e2-micro privadas em um MIG regional, scaling manual 2 → 3 → 2, NAT com IP reservado, regras restritas de firewall, uma conta de serviço de execução e snapshots diários dos discos de inicialização. Não exige organização, implantação dev separada, LB interno, roteamento central de auditoria ou módulos remotos.

## Recursos previstos

A tabela descreve o exemplo padrão com projeto novo, HTTP e duas réplicas. Quantidades e condições devem ser conferidas no plano real; VMs e discos são criados pelo MIG, não por recursos Terraform individuais.

| Recurso ou configuração | Quantidade/configuração padrão | Finalidade e implementação |
| --- | --- | --- |
| Projeto GCP | 1 projeto descartável com labels e vínculo a billing existente | Criado somente com `project_settings.create_project=true`; não cria conta de faturamento, organização ou pasta. [project.tf](infra/vm-web-platform/project.tf) |
| APIs | 6 APIs básicas e Monitoring no modo de criação | Compute, IAM, Logging, IAP, OS Login, Service Usage e Monitoring; no modo existente, apenas Monitoring é gerenciada aqui. [apis.tf](infra/vm-web-platform/apis.tf) |
| Identidade e IAM | 1 conta de serviço e 2 concessões de telemetria | Escrita de logs e métricas, sem chaves. [service-account.tf](infra/vm-web-platform/service-account.tf), [iam.tf](infra/vm-web-platform/iam.tf) |
| Rede | 1 VPC personalizada e 1 sub-rede regional | CIDR privado configurável; exemplo em us-central1. [network.tf](infra/vm-web-platform/network.tf) |
| Saída para internet | 1 Cloud Router, 1 Cloud NAT e 1 IPv4 regional reservado | Saída das VMs privadas para instalação de pacotes e telemetria. [nat.tf](infra/vm-web-platform/nat.tf) |
| Firewall | 5 regras | Permitir HTTP do LB/health checks, SSH do IAP e saída TCP 80/443; negar demais entradas e saídas abrangidas pelas regras. [firewall.tf](infra/vm-web-platform/firewall.tf) |
| Computação | 1 template e 1 MIG regional com 2 VMs em 2 zonas | e2-micro, IPs privados, Debian 12, OS Login e dispositivo de vídeo; expansão manual para 3 réplicas. [vm.tf](infra/vm-web-platform/vm.tf), [mig.tf](infra/vm-web-platform/mig.tf) |
| Discos | 1 disco de inicialização por VM | pd-standard de 10 GB no exemplo; exclusão automática com a VM. [vm.tf](infra/vm-web-platform/vm.tf) |
| Aplicação e agente | Nginx, página HTML e Ops Agent nas VMs | Instalados pelo script de inicialização; não são serviços gerenciados separados. [templates](infra/vm-web-platform/templates) |
| LB externo global | 1 backend service, 1 health check, 1 URL map, 1 proxy HTTP e 1 forwarding rule HTTP | Entrada HTTP na porta 80 e utilização-alvo de 80% nos backends. HTTPS adiciona proxy/regra próprios somente se habilitado e referencia certificados existentes. [load-balancers.tf](infra/vm-web-platform/load-balancers.tf) |
| IP do frontend | 1 IPv4 global reservado | Acesso ao LB; exibido no output lb_ip. [load-balancers.tf](infra/vm-web-platform/load-balancers.tf) |
| Backup | 1 política regional de snapshots vinculada aos discos | Execução diária, retenção de 7 dias, armazenamento us e início às 05:00 UTC (janela 02h–03h em Fortaleza). Os snapshots são gerados pelo agendamento, não necessariamente durante o apply. [snapshots.tf](infra/vm-web-platform/snapshots.tf) |

Não são criados bucket de estado, DNS, certificados, banco de dados ou autoscaler. O estado Terraform é local. As regras de firewall não concedem, sozinhas, permissões de acesso por IAP/OS Login.

## Testes automatizados

Consulte também o [resumo por categoria com resultados esperados](tests/README.md#categorias-e-resultados-esperados): projeto, arquitetura, rede e segurança, configuração, HTTP/HTTPS, scaling/snapshots e rejeição de entradas inválidas. Essas categorias correspondem às simulações Terraform; a tabela Python apresenta separadamente os critérios locais de aprovação.

Os **11 testes Python** verificam arquivos e renderização local. A [tabela detalhada dos testes Python](tests/README.md#tabela-dos-testes-python) apresenta cada teste, seu arquivo e o que verifica. As **30 simulações Terraform** verificam o plano com providers fictícios; a [tabela de suítes](tests/README.md#terraform-checks--owner-executed) descreve sua cobertura. Nenhum desses testes comprova o funcionamento real no GCP.

<a id="case-structure"></a>

## Estrutura do case

Os valores são organizados em oito objetos por responsabilidade no arquivo privado: projeto, implantação, rede, VMs, aplicação, LB, snapshots e identidade. Consulte o [guia de parâmetros](docs/deployment-inputs.md) e a [ADR 0017](docs/decisions/0017-responsibility-based-inputs.md). A implementação continua em um único diretório Terraform.

```text
docs/single-project-architecture.md  # Cenário e arquitetura atuais
docs/decisions/                     # Decisões, inclusive as substituídas
infra/vm-web-platform/              # Único diretório Terraform; ADC do usuário
infra/vm-web-platform/templates/    # Inicialização das VMs e HTML
infra/vm-web-platform/tests/        # Suítes de planos Terraform simulados
tests/                             # Testes Python ativos, ao lado de infra
```

<a id="operational-continuity"></a>

## Continuidade operacional

Os diretórios legados foram retirados da entrega pública. Código histórico, estados de seed/dev, backups e caches foram preservados na área privada de recuperação, fora deste case, conforme a [ADR 0016](docs/decisions/0016-private-legacy-recovery.md). Não houve migração de backend nem exclusão de recursos na nuvem. A [ADR 0014](docs/decisions/0014-single-architecture-root.md) registra a consolidação e os cuidados com o estado. O novo diretório começa com estado local protegido, separado do seed; nenhum estado é compartilhado ou importado. No modo de teste em projeto existente, as APIs básicas continuam sob responsabilidade do seed, e a nova configuração gerencia apenas a habilitação do Monitoring. No modo de novo projeto, ela gerencia a criação do projeto, o vínculo de faturamento, as labels e a habilitação das APIs; o destroy remove seus recursos e solicita a exclusão do projeto. Não é necessário aplicar seed/bootstrap. Não aplique o bootstrap antigo, não reative configurações descontinuadas de dev ou de múltiplos projetos, não reutilize planos antigos e não execute o controlador legado.

Os parâmetros privados compartilhados e o registro financeiro acumulado do portfólio permanecem em `.private/`, na raiz do repositório. Identificadores reais da nuvem nunca devem aparecer em exemplos ou evidências públicas. O limite acumulado de R$ 300 e a janela de testes de uma hora, incluindo a limpeza, permanecem inalterados. Inicie a desmontagem até o minuto 40. A retirada dos acessos do seed é uma operação separada, sujeita à revisão do responsável; seu prazo original de revisão continua sendo 2026-11-02.

As propostas anteriores preservam o desenho histórico com múltiplos projetos; não são instruções atuais de implantação. Os resultados funcionais adicionais foram confirmados pelo responsável, não observados independentemente pelo assistente. Não há alegação de limpeza automática, cumprimento medido da janela de uma hora, objetivo de tempo de recuperação atingido ou distribuição exata de tráfego.
