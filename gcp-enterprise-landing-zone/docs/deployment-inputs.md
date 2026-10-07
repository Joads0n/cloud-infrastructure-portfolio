<a id="deployment-values-and-implementation-boundaries"></a>

# Valores de implantação e limites da implementação

O usuário fornece os valores por um arquivo tfvars privado; o Terraform define as relações entre os recursos. Copie o [exemplo fictício completo](../infra/vm-web-platform/terraform.tfvars.example) para `.private/prod-simple.tfvars`, na raiz do repositório. Substitua o ID fictício do projeto, a conta de faturamento e a imagem antes de gerar o plano. O padrão `project_settings.create_project=true` cria um projeto de produção descartável, e o `destroy` exclui esse projeto após seus recursos gerenciados. Para nossos testes em projeto existente, defina explicitamente `project_settings.create_project=false` e omita ou deixe como null a conta de faturamento e os IDs da hierarquia. Nunca publique o arquivo resultante.

<a id="where-configuration-lives"></a>

## Onde fica a configuração

| Arquivo | Responsabilidade |
| --- | --- |
| `infra/vm-web-platform/terraform.tfvars.example` | Exemplo editável dos valores; nunca é carregado automaticamente |
| `infra/vm-web-platform/variables.tf` | Oito objetos por responsabilidade, com tipos, valores padrão e validações |
| `infra/vm-web-platform/project.tf`, `apis.tf`, `service-account.tf`, `iam.tf` | Preparação do projeto e identidade |
| `infra/vm-web-platform/network.tf`, `vm.tf` e demais arquivos por responsabilidade | Implementação direta dos recursos com os valores fornecidos |

Um único diretório raiz declara oito objetos independentes, e os arquivos de recursos os consomem diretamente; não há interface de módulo a sincronizar. O antigo settings.tf foi incorporado ao contrato único em variables.tf. Os valores padrão reproduzem o case fictício por conveniência; não são valores literais embutidos nos blocos de recursos.

As labels são independentes: use `project_settings.labels`, `compute_settings.labels` e `snapshot_settings.labels`. Não há labels comuns nem herança entre recursos. Omitir um mapa, usar null ou `{}` mantém somente as labels automáticas `environment=prod` e `managed_by=terraform`; os snapshots também recebem `backup_policy`. No modo `project_settings.create_project=false`, as labels do projeto existente não são gerenciadas. Alterar labels das VMs modifica o template e pode substituir réplicas; revise um plano novo antes de aplicar.

<a id="user-controlled-inputs"></a>

## Parâmetros controlados pelo usuário

| Objeto | Responsabilidade |
| --- | --- |
| `project_settings` | Projeto, faturamento, hierarquia e labels do projeto |
| `deployment_settings` | Região, prefixo e ambiente prod |
| `network_settings` | Nomes da VPC/sub-rede e CIDR; regras de firewall e NAT são definidas pela arquitetura |
| `compute_settings` | Zonas, imagem Debian, tipo de máquina, discos, réplicas, nome-base e labels das VMs |
| `application_settings` | Hostname compartilhado pela aplicação e pelo frontend HTTPS |
| `load_balancer_settings` | Nome, protocolos, aceite de HTTP, certificados e utilização máxima |
| `snapshot_settings` | Horário UTC, retenção, localização e labels dos snapshots |
| `identity_settings` | Nome da conta de serviço de execução |

`project_settings` e `compute_settings` são obrigatórios porque contêm ID de projeto e imagem, respectivamente. Os outros objetos podem ser omitidos para usar os padrões fictícios. O projeto não é regional: a localização dos recursos fica em `deployment_settings`. Todas as declarações e validações estão em `variables.tf`.

Não há recurso de bucket, parâmetro de storage nem arquivo de backend remoto nesta frente. O Terraform mantém seu estado localmente, fora do Git, durante todo o ciclo de vida. Preservar esse arquivo e seus backups continua sendo obrigatório; estado não é um recurso opcional do Terraform.

| Parâmetro | Finalidade e restrições |
| --- | --- |
| `project_settings.create_project` | Padrão true: criar e excluir um projeto descartável; false: nunca assumir/excluir um projeto de teste existente |
| `project_settings.project_id`, `project_settings.project_name` | ID globalmente único e nome de exibição do projeto; o modo existente utiliza somente o ID |
| `project_settings.billing_account_id` | Conta de faturamento existente a vincular no modo de criação; null no modo existente |
| `project_settings.organization_id`, `project_settings.folder_id` | Organização ou pasta existente opcional para criação; no máximo uma; nenhuma no modo existente |
| `compute_settings.image` | Caminho exato de uma imagem oficial Debian 12; o script de inicialização é específico para Debian, não genérico para qualquer sistema operacional |
| `identity_settings.runtime_service_account_id` | Nome da nova conta de execução, não uma identidade existente a importar |
| `compute_settings.backend_count` | Duas ou três réplicas, dentro dos limites de scaling manual deste case |
| `load_balancer_settings.allow_public_http` | Aceite explícito separado, obrigatório sempre que HTTP estiver habilitado |
| `deployment_settings.resource_prefix` | Prefixo dos nomes derivados, inclusive roteador, NAT, firewall, tags e política de snapshots |
| `network_settings.vpc_name`, `network_settings.subnet_name` | Nomes exatos opcionais para rede e sub-rede |
| `compute_settings.vm_base_name` | Nome do MIG e nome-base das VMs; o GCP gera os sufixos de cada réplica |
| `load_balancer_settings.lb_name` | Nome compartilhado pelo frontend, mapa de URLs e verificação de integridade do LB; os componentes HTTPS recebem um sufixo |
| `deployment_settings.region`, `compute_settings.zones` | Uma região e exatamente duas zonas distintas para as VMs dentro dela; atualize ambos em conjunto |
| `network_settings.subnet_cidr` | Faixa IPv4 privada RFC1918; verifique sobreposição e capacidade separadamente |
| `application_settings.hostname` | Nome de host do Nginx e endpoint HTTPS; não cria zona nem registro DNS |
| `compute_settings.machine_type`, `compute_settings.boot_disk_type`, `compute_settings.boot_disk_size_gb` | Dimensionamento da VM e do disco; valores maiores podem aumentar significativamente o custo |
| `compute_settings.enable_display` | Dispositivo de vídeo virtual |
| `snapshot_settings.labels` | Labels exclusivas dos snapshots; até 61 entradas, com environment/managed_by/backup_policy reservadas |
| `project_settings.labels` | Labels independentes do projeto criado; não altera labels de projeto existente quando create_project=false |
| `compute_settings.labels` | Labels independentes das VMs, aplicadas pelo template do MIG a todas as réplicas |
| `load_balancer_settings.backend_max_utilization` | Utilização-alvo do LB; não é autoscaler nem limite rígido de CPU |
| `snapshot_settings.start_time` | Hora inicial em UTC; mudar a região não converte esse valor automaticamente |
| `snapshot_settings.retention_days`, `snapshot_settings.location` | Retenção e local de armazenamento; verifique compatibilidade e custos |
| `load_balancer_settings.enable_http`, `load_balancer_settings.enable_https`, `load_balancer_settings.ssl_certificate_ids` | Escolha dos frontends e referências a certificados SSL globais existentes do Compute |

Quando omitidos, os nomes opcionais dos recursos são derivados do prefixo. Nomes informados explicitamente não mudam automaticamente quando o prefixo é alterado. Alterações de nome podem provocar substituições; sempre revise um plano novo. Não presuma a contagem inicial de 23 recursos após mudar frontends ou outros parâmetros.

<a id="http-and-https"></a>

## HTTP e HTTPS

Dentro de `load_balancer_settings`, pelo menos um frontend deve estar habilitado:

- Somente HTTP: `enable_http = true`, `enable_https = false`, `load_balancer_settings.allow_public_http = true`.
- Somente HTTPS: `enable_http = false`, `enable_https = true`, além dos IDs de certificados existentes. O aceite de HTTP pode permanecer false.
- Ambos: habilite os dois e aceite explicitamente o HTTP público. Ambos servem a aplicação; não há redirecionamento implícito.

O TLS termina no Application Load Balancer global externo. Os backends privados e as verificações de integridade continuam em HTTP na porta 80, protegidos pelo firewall existente. Informe IDs de certificados SSL globais do Compute pela [interface de certificados do proxy HTTPS](https://registry.terraform.io/providers/hashicorp/google/7.28.0/docs/resources/compute_target_https_proxy) do provider. Essa interface não aceita IDs ou mapas do Certificate Manager. A configuração referencia certificados, mas não os cria, importa, renova nem exclui, e nunca recebe chaves privadas.

Antes de implantar HTTPS, verifique independentemente se o certificado está pronto, se é compatível com o projeto de destino, se cobre o nome de host e se o DNS resolve para o IP do LB. O nome fictício `.example` não é um domínio registrável publicamente nem fornece um certificado de confiança pública. Certificados privados de laboratório exigem configuração de confiança no cliente; não desative a verificação TLS para alegar validação bem-sucedida. HTTPS exige validação própria em execução e revisão de custos; nenhuma implantação HTTPS é alegada.

`endpoint` retorna a URL HTTPS baseada no nome de host quando habilitada; caso contrário, retorna a URL HTTP com o IP. `lb_ip` sempre informa o endereço reservado do frontend. Nenhum desses outputs configura DNS.

<a id="what-remains-part-of-the-architecture"></a>

## O que permanece como parte da arquitetura

Um projeto de produção, uma VPC/sub-rede, um MIG regional em duas zonas, interfaces privadas nas VMs, um Application Load Balancer global externo, NAT de saída, IAP/OS Login, entrada restrita aos proxies e verificações de integridade do Google, Ops Agent instalado na inicialização, snapshots diários e exclusão automática dos discos de inicialização continuam sendo decisões de arquitetura. Portas dos protocolos, faixas de origem dos serviços Google, referências entre recursos Terraform, papéis de telemetria e controles de inicialização segura são invariantes da implementação, não valores arbitrários de implantação.

Os padrões de snapshots continuam sendo sete dias, localização multirregional US e janela de início entre 02:00 e 03:00 no horário de Fortaleza. Parâmetros diferentes descrevem outra implantação da mesma topologia; não comprovam custo, disponibilidade ou resultados de teste equivalentes.

<a id="safe-upgrade-and-validation"></a>

## Atualização segura e validação

A [ADR 0017](decisions/0017-responsibility-based-inputs.md) registra a nova interface. Não misture os parâmetros antigos com os novos objetos: o Terraform não combina essas interfaces. Converta o arquivo privado a partir do exemplo, preservando valores, modo de projeto e labels. Parâmetros desconhecidos ou avisos de variável não declarada devem ser corrigidos antes do apply.

No refinamento de zonas e labels, mova zones de deployment_settings para compute_settings e remova o antigo campo labels de deployment_settings. Se projeto ou VMs dependiam do mapa comum, copie suas entradas explicitamente para o mapa do recurso; para preservar labels de snapshots, copie-as para snapshot_settings.labels. A conversão é necessária: atributos extras de objetos podem ser descartados pelo Terraform sem aviso.

Para scaling, edite **somente** `backend_count` dentro do bloco `compute_settings` no arquivo privado, de 2 para 3 e depois de volta para 2, gerando e revisando um plano em cada etapa. O antigo argumento de linha de comando para a variável isolada não existe mais. Não substitua `compute_settings` por um objeto contendo apenas a quantidade: objetos fornecidos por outro arquivo ou argumento substituem o objeto inteiro, não mesclam atributos, e a imagem continua obrigatória.

Use um plano novo gerado pelo responsável; não reutilize planos salvos. Nunca altere `project_settings.create_project` ou o ID do projeto de destino enquanto esse estado gerenciar recursos: o Terraform poderá propor a exclusão ou substituição do projeto. Um projeto criado por esse modo é inteiramente descartável; não coloque aplicações, dados ou certificados alheios ao laboratório nele. Consulte o [guia de ciclo de vida do projeto](../infra/README.md#project-lifecycle-and-evaluator-flow). Os recursos HTTP usam `[0]` para permitir desabilitar esse frontend. `migrations.tf` mapeia os recursos da estrutura anterior, baseada em módulo, para este diretório raiz. Essas declarações não movem arquivos de estado nem trocam projetos. Não havia estado de produção durante a consolidação; quem tiver uma implantação existente precisa revisar separadamente a migração de estado/backend e proteger um backup antes de usar o novo diretório. Nunca copie estados históricos de dev ou seed para ele. Habilitar/desabilitar protocolos e alterar nomes, região ou CIDR pode adicionar, destruir ou substituir recursos.

Todos os planos, inclusive simulados, e todas as operações apply/destroy continuam sob execução do responsável. Mantenha o limite acumulado de R$ 300 do portfólio e a sessão acompanhada de uma hora, incluindo a limpeza. Certificados, DNS, telemetria e snapshots remanescentes exigem inventário e conciliação financeira separados. As evidências anteriores de dev não foram alteradas e não validam parâmetros personalizados nem HTTPS.
