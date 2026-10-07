<a id="single-project-workload-runbook"></a>

# Guia operacional da implantação em projeto único

O fluxo deste laboratório usa somente estado local: init, plan, apply e destroy. Não há bucket de estado nem etapa de migração. Preserve cópias privadas independentes e use apenas um operador. Não apague o estado antes de concluir a destruição. Consulte a [ADR 0018](../docs/decisions/0018-local-state-only.md).

A configuração é separada da implementação: use o [guia de parâmetros](../docs/deployment-inputs.md) e o exemplo completo de tfvars. Os valores abaixo — nomes, região, dimensionamento, HTTP e snapshots — descrevem a configuração fictícia padrão. O HTTPS opcional exige um certificado SSL global do Compute existente e pronto, além de nome de host e DNS compatíveis; nenhum certificado ou recurso DNS é criado aqui. Qualquer alteração de valores ou protocolos exige um plano novo revisado pelo responsável e verificações adequadas em execução.

Configuração de referência atual: a [ADR 0010](../docs/decisions/0010-vm-telemetry-and-snapshot-adjustments.md) registra os ajustes aceitos de telemetria, dispositivo de vídeo, snapshots e LB. A configuração acrescenta duas concessões de escrita de telemetria e habilita a Monitoring API, mantida habilitada após o destroy. Logging permanece sob responsabilidade do seed somente no modo de projeto existente; o modo de novo projeto habilita todas as APIs necessárias à implantação. Os snapshots usam `us` e começam entre 02:00 e 03:00 no horário de Fortaleza. O template habilita o dispositivo de vídeo e instala o Ops Agent na inicialização; a utilização dos backends é 0,8. `lb_ip` exibe intencionalmente o endereço público. Gere um plano novo revisado pelo responsável; não reutilize o plano antigo de implantação. A proteção contra exclusão por VM continua indisponível no MIG.

Somente `infra/vm-web-platform` é o diretório Terraform ativo. Leia a [arquitetura](../docs/single-project-architecture.md) e a [ADR 0011](../docs/decisions/0011-single-production-project.md). Não aplique seed/bootstrap/dev como parte deste procedimento. Todos os planos, suítes de planos simulados, applies e operações de destruição são executados pelo responsável.

<a id="prerequisites-and-safety-boundary"></a>

## Pré-requisitos e limites de segurança

O modo padrão do avaliador cria um projeto, vincula uma conta de faturamento existente, aplica labels e habilita as APIs antes de criar os recursos. Não cria conta de faturamento, organização, pasta nem chave. O modo de teste em projeto existente (`project_settings.create_project=false`, parâmetros de faturamento/hierarquia null) nunca assume o projeto nem o gerenciamento de suas APIs básicas; somente habilita Monitoring e adiciona os recursos e permissões da implantação. Verifique cotas, permissões, disponibilidade da imagem e conflitos de nomes para o modo escolhido.

Use Application Default Credentials (ADC) do usuário; verifique as identidades de ADC e da CLI e rejeite sobrescritas inesperadas de credenciais ou impersonação. A implantação exige permissões adequadas para Compute, criação/uso de contas de serviço, habilitação de serviços pelo Service Usage e leitura/escrita de IAM do projeto para as concessões restritas de telemetria. A administração por IAP/OS Login e o acesso dos agentes de serviço precisam ser verificados separadamente: criar uma regra de firewall não concede autorização SSH. Não resolva falta de permissões concedendo Owner automaticamente.

Uma conta de execução é criada aqui, somente com `roles/logging.logWriter` e `roles/monitoring.metricWriter`. O bootstrap arquivado também descreve esse nome; nunca aplique as duas configurações. Se a conta já existir ou houver estado desses recursos em outro local, interrompa o processo para revisar a responsabilidade por eles, em vez de importar ou recriar automaticamente.

<a id="toolchain-update-and-local-executable"></a>

## Versões das ferramentas e executável local

Versões fixadas: Terraform 1.16.5, `google` 8.5.0 e `google-beta` 8.5.0 para o template com dispositivo de vídeo habilitado. O comando `terraform` do responsável já está configurado; não é necessário sobrescrever PATH rotineiramente. Na raiz do repositório:

```sh
umask 077
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform init -backend=false -lockfile=readonly
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform validate
terraform -chdir=gcp-enterprise-landing-zone/infra fmt -check -recursive
```

A validação dos providers não exige um plano em nuvem. O diretório começa com backend local: antes de um plano real, o responsável deve inicializá-lo normalmente. Nenhum estado foi copiado durante a consolidação. Consulte a [ADR 0014](../docs/decisions/0014-single-architecture-root.md) e os [limites do estado neste diretório](vm-web-platform/README.md#state-boundary-after-consolidation). Se forem encontrados metadados GCS inesperados ou estado de outro diretório, pare; não use migração automática, force-copy ou reconfigure sem análise. Não havia estado dos recursos de produção nesta reestruturação. Preserve o estado vazio de dev e seus backups na área privada de recuperação; nunca os copie para produção. O cache histórico de providers/backend de produção não comprova uma implantação. Inspecione-o antes da inicialização normal; se referenciar GCS ou outro diretório, interrompa o processo para uma decisão explícita de recuperação.

<a id="private-inputs-and-state"></a>

## Parâmetros privados e estado

Leia a seção de ciclo de vida abaixo antes de preparar os parâmetros. Copie a estrutura de [terraform.tfvars.example](vm-web-platform/terraform.tfvars.example) para um novo arquivo privado ignorado pelo Git, `.private/prod-simple.tfvars`, na raiz do repositório, substituindo os valores fictícios de projeto/imagem de forma privada. Não reutilize arquivos antigos contendo identidades de provisionamento/execução. Mantenha `load_balancer_settings.allow_public_http=false` até aceitar a exposição HTTP de conteúdo sintético.

Defina nomes, região/zonas, CIDR, dimensionamento das VMs/discos, labels, utilização do LB, snapshots e protocolos do frontend pelos oito objetos de configuração; não é necessário editar blocos de recursos. Pelo menos um frontend precisa estar habilitado. O aceite de HTTP só é obrigatório quando `load_balancer_settings.enable_http=true`; HTTPS exclusivo também exige IDs de certificados. Use os nomes e labels realmente configurados nas verificações abaixo, em vez de copiar seletores de exemplo sem adaptação. Após alterar o prefixo, a label de inventário dos snapshots será `backup_policy=<resource_prefix>-daily`.

O estado da implantação começa localmente no diretório de produção. Use permissões restritas de arquivo, armazenamento criptografado na estação e cópias independentes e protegidas de recuperação após cada operação que grave estado. Git ignore não é backup. Somente um operador deve usar esse estado; não execute Terraform simultaneamente. Backend remoto está fora do escopo desta frente.

<a id="owner-operated-plan-and-deployment"></a>

## Plano e implantação executados pelo responsável

Antes de gerar o plano, inspecione a identidade do backend, os parâmetros privados, o estado atual, o escopo do projeto, as credenciais, o saldo disponível do orçamento e os conflitos de nomes. Na raiz do repositório, após garantir que o arquivo de plano ainda não existe:

```sh
umask 077
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform init -lockfile=readonly
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform plan \
  -input=false -lock-timeout=60s \
  -var-file="$PWD/.private/prod-simple.tfvars" \
  -out="$PWD/.private/prod-simple-reviewed.tfplan"
```

Revise o plano antes de aplicá-lo. O escopo esperado inclui uma conta de execução, duas concessões aditivas de escrita de telemetria, habilitação da Monitoring API e os recursos Compute deste projeto. Criação do projeto, vínculo de faturamento, labels e habilitação das APIs básicas pertencem somente ao plano do modo padrão de criação. Nenhuma política organizacional, roteamento central de auditoria, implantação de gerenciamento/dev ou concessão explícita de papel administrativo pertence a qualquer um dos modos. A revisão anterior de dev, com estado vazio, continha 23 adições; não presuma a mesma contagem nos planos futuros. Planos contêm dados privados: compartilhe resumos de ações sem informações sensíveis, não os arquivos brutos. Quando HTTP estiver habilitado, seu aceite é obrigatório; uma imagem válida com versão exata também é necessária para um plano implantável.

Antes de nova implantação, verifique o saldo restante do orçamento único do portfólio, cobranças atrasadas e recursos retidos; prepare o cronograma acompanhado de uma hora e a limpeza manual. Não é exigida uma estimativa detalhada separada por case. Esta configuração não tem monitor automático de prazo. Inicie a contagem antes do apply, comece a desmontagem até o minuto 40 ou antes e deixe de executar testes se a preparação atrasar. O controlador e seus testes foram retirados da entrega pública e preservados na recuperação privada; não há pasta scripts ativa nem monitor automático de prazo.

<a id="planned-runtime-checks"></a>

## Verificações previstas em execução

Após o `terraform apply` concluir com sucesso, reserve aproximadamente **2 a 5 minutos** para a página ficar disponível pelo IP do LB (`lb_ip`). Esse prazo é estimado: depende da execução do script de inicialização, da instalação e partida do Nginx e das verificações de integridade do balanceador. A conclusão do apply não comprova disponibilidade da aplicação. Confirme os dois backends como `HEALTHY` e uma resposta HTTP bem-sucedida antes de registrar o teste como aprovado. Se a página continuar indisponível, examine a saúde dos backends, os logs do script de inicialização, o serviço Nginx e a conectividade de saída pelo NAT; não reaplique o Terraform apenas para tentar acelerar a disponibilidade. A espera faz parte da sessão de uma hora e não adia o início da limpeza previsto até o minuto 40.

A página exibe em destaque um identificador de backend por VM e uma cor derivada do token, mantendo também a identidade no cabeçalho da resposta. A identidade persiste em disco entre reinicializações, mas muda quando o MIG cria uma VM substituta. Não há numeração permanente de VM 1/VM 2; o mecanismo também funciona para uma terceira réplica. As cores são uma indicação secundária, sem garantia de exclusividade; compare o identificador. O botão de atualização faz uma requisição real, não simula a troca de backend. As conexões do navegador e a seleção do LB podem retornar o mesmo backend repetidamente.

1. Verifique duas VMs privadas, ambos os backends saudáveis, as regras de firewall esperadas e os endereços reservados do frontend/NAT.
2. Resolva privadamente `app.cedar-route.example` para o IP do LB com `--resolve` do curl; não é necessário registrar DNS real. Capture os dois tokens aleatórios dos backends em um número limitado de requisições; não exija alternância estrita.
3. Em exercício de falha aprovado separadamente, pare o Nginx em exatamente uma réplica, meça o comportamento de saúde/erros, reinicie-o e verifique a recuperação.
4. No arquivo privado, altere apenas `backend_count` dentro de `compute_settings` para 3 com plan/apply revisados pelo responsável, observe a terceira réplica e restaure 2 com outro plan/apply revisado. Não use o antigo argumento isolado de backend_count nem sobrescreva o objeto com apenas a quantidade: isso perderia os demais atributos, inclusive a imagem obrigatória. Isso é scaling manual, não autoscaling.
5. Inspecione o vínculo da política de snapshots de cada disco de inicialização, inclusive das novas réplicas. Snapshots diários podem não ocorrer dentro da sessão de uma hora. Um snapshot sob demanda e um exercício de restauração aprovados separadamente testam recuperação, não o agendador. Aplique a label `backup_policy=crl-prod-daily` aos snapshots manuais para inventário e exclua os discos de teste restaurados.
6. Verifique SSH via IAP com OS Login, ausência de IP público nas VMs e bloqueio de acesso não autorizado aos backends. Uma política diária, isoladamente, não é evidência de restauração.

<a id="costs-and-cleanup"></a>

## Custos e limpeza

Execute terraform destroy com os mesmos parâmetros e o estado local usado na implantação. Não é necessário alterar código, liberar force_destroy, executar apply direcionado ou migrar estado antes da limpeza. Se estiver usando uma configuração antiga com backend remoto, interrompa o uso deste fluxo até revisar sua recuperação separadamente.

O limite de R$ 300 inclui todos os cases, seed, novas tentativas, snapshots, IPs externos, NAT, LB, VMs/discos, tráfego, artefatos retidos e cobranças atrasadas. Use um registro financeiro global, não uma estimativa detalhada separada para cada case. Antes da sessão, revise serviços faturáveis, duração, custos remanescentes e uma reserva conservadora por sessão quando necessário. A estimativa anterior do laboratório combinado é histórica, não uma cotação atual. O último relato de gasto zero antes dos testes não é faturamento verificado após os testes nem garantia de ausência de cobranças atrasadas. O limite de R$ 300 é operacional, não um bloqueio rígido de gastos no GCP.

Somente o responsável executa planos/applies de destruição sobre o estado de produção. Mantenha a identidade de execução até a remoção das VMs associadas; as dependências Terraform definem a ordem. Confirme a remoção das VMs do MIG, discos, template, componentes do LB, ambos os endereços reservados, roteador/NAT, regras de firewall, sub-rede/VPC, conta de execução, política de snapshots e ambas as concessões IAM de telemetria. A Monitoring API permanece habilitada intencionalmente (`disable_on_destroy=false`); a telemetria armazenada segue sua própria retenção. No modo de projeto existente, nunca exclua o projeto existente nem o estado do seed. No modo de criação, as dependências preservam o projeto até a remoção de seus recursos gerenciados; depois, o Terraform solicita sua exclusão. Não misture recursos alheios ao laboratório nesse projeto descartável.

Os snapshots gerados ficam fora do estado Terraform. Inventarie snapshots com `backup_policy=crl-prod-daily` e os discos de origem específicos, mesmo quando o Terraform informar zero recursos. Revise os identificadores exatos antes de excluir snapshots ou discos restaurados remanescentes. Remover o agendamento/disco de origem não exclui snapshots imediatamente; a retenção de sete dias solicitada pelo responsável não é um prazo rígido de limpeza. Snapshots retidos podem continuar gerando cobranças após a sessão de VMs de uma hora. Concilie cobranças atrasadas e preserve evidências protegidas de estado/recuperação. É necessário um plan/apply novo gerado pelo responsável para alterar a retenção implantada; planos antigos salvos ainda contêm o valor anterior.

<a id="known-limitations"></a>

## Limitações conhecidas

HTTP é uma exceção explícita para dados sintéticos; o nome de host fictício não fornece certificado TLS público. O Nginx não mantém estado e não há banco de dados nem funcionalidade de negócio. Não se trata de governança organizacional, recuperação de desastres multirregional, recuperação automática da aplicação ou autoscaling. Substituições de template podem interromper o serviço. NAT e repositórios de pacotes são dependências da inicialização. Consulte o [registro de evidências](../docs/single-project-validation.md) para distinguir resultados observados e relatos do responsável. A saúde inicial dos backends e o acesso à página não comprovam telemetria, recuperação de falhas, scaling, restauração de snapshots, inventário completo de remanescentes nem cumprimento da meta de uma hora.

Nos testes HTTPS, use o nome de host configurado com verificação normal do certificado e confirme que o certificado é servido pelo LB. Quando HTTP estiver desabilitado, verifique a ausência de exposição da porta 80 por regra de encaminhamento. Quando ambos estiverem habilitados, ambos servem conteúdo sem redirecionamento de HTTP para HTTPS. O TLS termina no LB; Nginx e verificações de integridade dos backends continuam usando HTTP privado. Certificados referenciados e DNS externo ficam fora da limpeza dos recursos e precisam de revisão separada.

Os discos de inicialização mantêm `auto_delete = true`, conforme confirmado pelo responsável após recusar a mudança para MIG stateful. A exclusão da VM remove seu disco de inicialização associado com exclusão automática; a retenção de snapshots é independente. Não há alegação de preservação de discos nem de proteção contra exclusão por VM.

<a id="project-lifecycle-and-evaluator-flow"></a>

## Ciclo de vida do projeto e fluxo do avaliador

O fluxo normal do avaliador usa um diretório Terraform, um arquivo privado de valores e um fluxo de apply/destroy. Não é necessário executar seed/bootstrap.

1. Autentique-se com ADC do usuário. São necessárias permissões para criar/excluir projetos na hierarquia escolhida, quando aplicável, associar a conta de faturamento existente, habilitar serviços e gerenciar os recursos/IAM do laboratório. A organização/pasta opcional já deve existir. Sua conta precisa ter cota disponível para projetos.
2. Prepare o contexto local de credenciais/cotas antes de criar o projeto. Se suas credenciais exigirem um projeto de cotas, use um projeto existente autorizado, com acesso a Resource Manager, Cloud Billing e Service Usage habilitado. O destino ainda não criado não pode preparar as credenciais do próprio operador nem seu contexto de cotas. Esse contexto é externo ao case e não deve ser excluído por ele.
3. Copie o exemplo completo para parâmetros privados ignorados pelo Git. Substitua ID do projeto, conta de faturamento e imagem Debian com versão exata. O exemplo aceita explicitamente HTTP público para conteúdo sintético; revise essa escolha. Mantenha o padrão `project_settings.create_project=true` somente para projeto novo e descartável.
4. Execute init, plan e revisão neste diretório com os comandos acima; depois, aplique o plano salvo. O Terraform cria o projeto com faturamento/labels, habilita APIs, cria a identidade de execução/permissões e implanta os recursos na ordem das dependências. Os nomes dos arquivos não definem a ordem.
5. Após o apply, teste e limpe dentro da janela acompanhada de tempo/orçamento, usando os mesmos parâmetros e estado local. O destroy remove os recursos gerenciados e solicita a exclusão do projeto criado; não exige bootstrap nem migração de backend.

Exemplos de comandos executados pelo responsável na raiz do repositório, após revisar o plano de implantação salvo:

```sh
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform apply "$PWD/.private/prod-simple-reviewed.tfplan"
# Revise o alvo: no modo create_project=true, o projeto criado também será excluído.
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform destroy \
  -var-file="$PWD/.private/prod-simple.tfvars"
```

O destroy mantém a confirmação interativa; não é recomendado `-auto-approve`. A exclusão do projeto usa `deletion_policy="DELETE"`. Ela exclui o projeto criado inteiro, inclusive recursos adicionados fora do Terraform. O GCP coloca o projeto excluído em um período de recuperação, em vez de apagá-lo imediatamente; consulte o [ciclo de exclusão de projetos do Google](https://docs.cloud.google.com/resource-manager/docs/delete-restore-projects?hl=en). Confirme a solicitação de exclusão e concilie cobranças atrasadas; não alegue apagamento irreversível instantâneo nem custo remanescente zero.

Para nossos testes em projeto existente, defina explicitamente `project_settings.create_project=false`, `project_settings.billing_account_id=null`, `project_settings.organization_id=null` e `project_settings.folder_id=null`. As APIs básicas e o faturamento já devem estar configurados; o seed anterior não é reaplicado. O destroy remove apenas os recursos deste estado, não o projeto, seu vínculo de faturamento nem recursos alheios ao laboratório. Monitoring permanece habilitado, e snapshots manuais/discos restaurados continuam sujeitos a inventário separado.

Nunca altere o ID do projeto nem o modo de ciclo de vida em um estado que gerencie recursos. Primeiro destrua com os parâmetros originais; preserve registros protegidos de estado/recuperação. Não importe um projeto existente para o recurso de projeto descartável.

<a id="implementation-file-map"></a>

## Mapa dos arquivos de implementação

```text
gcp-enterprise-landing-zone/
  infra/
    README.md                   # Guia operacional
    vm-web-platform/            # Único diretório de execução Terraform
      terraform.tfvars.example  # Modelo de valores para o usuário
      variables.tf              # Oito objetos por responsabilidade
      versions.tf, providers.tf # Ferramentas e providers
      backend.tf                # Estado local durante todo o ciclo de vida
      project.tf                # Projeto, faturamento, labels e ciclo de vida
      apis.tf                   # Habilitação de APIs
      service-account.tf        # Identidade de execução
      iam.tf                    # Concessões de telemetria
      network.tf                # VPC e sub-rede
      nat.tf                    # Roteador, NAT e IP de saída reservado
      firewall.tf               # Regras de entrada/saída
      vm.tf                     # Template, discos e inicialização
      mig.tf                    # Grupo regional e capacidade manual
      load-balancers.tf         # Saúde, backend e frontend HTTP(S)
      snapshots.tf              # Política diária de snapshots
      locals.tf, outputs.tf
      migrations.tf             # Mapeamentos do antigo módulo para a raiz
      templates/                # Inicialização Bash e HTML sintético
      tests/                    # Planos simulados executados pelo responsável
  tests/                        # Testes Python ativos, ao lado de infra
```

Recursos relacionados compartilham um arquivo por responsabilidade. Não há módulo filho, seletor de ambiente nem controlador ativo de sessão. O Terraform carrega todos os arquivos em conjunto e segue dependências, não a ordem dos nomes.

Os diretórios antigos de seed/bootstrap/dev/controlador e módulos foram retirados do case. Seus códigos, estados, backups e caches foram preservados sob `.private/recovery/`, na raiz do repositório, conforme a [ADR 0016](../docs/decisions/0016-private-legacy-recovery.md). Não execute Terraform na recuperação nem copie seus estados para o diretório consolidado. A manutenção do seed exige revisão separada com seu contexto original de estado/backend.

Nenhum estado de produção foi encontrado durante a consolidação. Quem utiliza a estrutura anterior com módulo precisa revisar a migração de estado/backend antes de executar aqui; `migrations.tf`, isoladamente, não move arquivo de estado. Nunca comece com estado vazio sobre recursos implantados nem reutilize planos antigos.
