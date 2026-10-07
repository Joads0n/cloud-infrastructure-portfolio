<a id="single-project-validation-and-session-evidence"></a>

# Validação do projeto único e evidências das sessões

Atualizado em: 2026-10-07. Este registro distingue inspeção de código, observações diretas e relatos do responsável. Não contém IDs reais de projetos, endereços de endpoints, credenciais, planos brutos nem capturas de console.

## Revisão atual: estado local sem bucket — 2026-10-07

A [ADR 0018](decisions/0018-local-state-only.md) retira o bucket e o fluxo GCS. Os resultados anteriores abaixo são históricos e não comprovam uma implantação desta versão simplificada.

Na execução anterior com bucket, o responsável informou um plano de 32 adições, confirmou apply concluído e acesso à página pelo LB, e forneceu a saída dos 11 testes Python aprovados. Durante a limpeza, relatou falha de persistência de estado por exclusão do bucket que ainda era backend ativo. O assistente verificou diretamente o projeto em DELETE_REQUESTED, preservou as cópias de recuperação e restaurou o estado local de mesma linhagem, serial 43 e sem recursos gerenciados. O backend local foi inicializado com sucesso e state list retornou vazio. Posteriormente, o responsável confirmou o projeto como excluído e encerrou a operação. Não há alegação de apagamento imediato definitivo, ausência de custos atrasados nem validação de recuperação por soft delete.

Nenhuma nova operação no GCP foi executada na retirada do código do bucket. Estados e backups privados foram preservados. Um novo plano real e uma nova sessão são necessários caso o responsável queira validar a revisão sem bucket na nuvem.

Validação local da revisão sem bucket: terraform validate e formatação aprovados, 30 testes Terraform com providers simulados e 11 testes Python aprovados. As duas simulações específicas do bucket foram removidas; os testes Python de estado agora verificam o uso exclusivo do backend local e a ausência da infraestrutura remota. Nenhum plano real foi gerado. Os hashes do estado local recuperado, do arquivo de erro preservado e dos parâmetros privados permaneceram iguais.

## Interface por responsabilidade — 2026-10-07

Refinamento posterior: zonas movidas para compute_settings, sem labels configuráveis em deployment_settings. Projeto, VMs e snapshots usam mapas independentes; bucket somente labels automáticas. Passaram 32 testes Terraform simulados, 11 testes Python, formatação e 251 verificações de links. O arquivo privado foi convertido com backup e preservação das labels efetivas de projeto/VMs/snapshots e dos demais valores; a retirada das labels personalizadas do bucket é intencional. Nenhum plano real ou apply foi executado.

A [ADR 0017](decisions/0017-responsibility-based-inputs.md) reorganiza os parâmetros em oito objetos. Passaram terraform validate, as 29 simulações Terraform, os 11 testes Python e a formatação. A comparação dos 18 arquivos Terraform fora das declarações de variáveis confirmou apenas alterações de referências de entrada, sem mudanças nos endereços, dependências ou valores literais dos recursos. O arquivo privado foi convertido com backup protegido e conferência de preservação dos 31 campos informados. Nenhum plano real, apply, importação ou migração de backend foi executado nesta reorganização. O teste ponta a ponta continua pendente.

<a id="production-scope--2026-10-06"></a>

## Escopo de produção — 2026-10-06

O ponto de execução ativo agora é `infra/vm-web-platform/`, sem módulo filho nem seletor de ambiente ([ADR 0014](decisions/0014-single-architecture-root.md)). Os testes Python permanecem ao lado de infra. Os diretórios legados foram retirados do case e preservados, junto com seus estados, backups e caches, na recuperação privada ([ADR 0016](decisions/0016-private-legacy-recovery.md)). A movimentação local não alterou os hashes dos estados nem migrou o backend. Nenhum estado de produção foi encontrado ou copiado para o novo diretório.

A revisão mais recente acrescenta criação de projeto, faturamento, labels e APIs por padrão, além de um modo explícito de teste em projeto existente ([ADR 0013](decisions/0013-disposable-project-and-resource-files.md)). Não houve criação de projeto, alteração de faturamento ou exclusão nessa revisão. Declarações anteriores sobre um único projeto existente descrevem a revisão precedente. Os planos anteriores não devem ser reutilizados.

A configuração ativa tem como alvo um único projeto de produção ([ADR 0011](decisions/0011-single-production-project.md)). Nenhum plano, apply ou verificação em execução de produção foi realizado para esta revisão. Todas as observações em nuvem e marcações confirmadas pelo responsável abaixo pertencem ao teste anterior em dev, não a produção. O estado local de dev foi inspecionado e contém zero recursos gerenciados; ele está preservado na recuperação privada, separado do seed. Nenhum estado de recursos de produção foi encontrado. Essa inspeção local não é um inventário de recursos remanescentes na nuvem.

Produção exige um arquivo privado de parâmetros novo, revisão dos pré-requisitos e conflitos de nomes no projeto de destino e um plano gerado pelo responsável. A nova aceitação em execução é independente da preservação das evidências de dev.

<a id="cloud-sessions-and-evidence--historical-dev-trial"></a>

## Sessões em nuvem e evidências — teste histórico em dev

<a id="owner-confirmed-test-checklist"></a>

## Lista de testes confirmados pelo responsável

Para o teste em dev, o responsável confirmou posteriormente que as categorias abaixo foram testadas e validadas. **✓ significa sucesso confirmado pelo responsável, não verificação independente do assistente.** Nenhuma saída adicional de comandos, captura de tela, horário de execução ou medição foi anexada à confirmação. As observações anteriores permanecem como registros históricos do que estava disponível naquele momento.

| Categoria | Situação | Base da evidência |
| --- | --- | --- |
| Acesso à aplicação | ✓ Testado e validado | Confirmação do responsável; o acesso inicial à página também havia sido relatado |
| Ops Agent e ingestão de logs/métricas | ✓ Testado e validado | Confirmação do responsável; artefatos técnicos não anexados |
| Distribuição de tráfego do LB entre backends | ✓ Testado e validado | Confirmação do responsável; artefatos técnicos não anexados |
| Scaling manual 2 → 3 → 2 | ✓ Testado e validado | Confirmação do responsável; artefatos técnicos não anexados |
| Falha e recuperação de backend | ✓ Testado e validado | Confirmação do responsável; artefatos técnicos não anexados |
| Criação de snapshot e restauração de disco | ✓ Testado e validado | Confirmação do responsável; artefatos técnicos não anexados; não comprova execução pelo agendador diário |
| Limpeza dos recursos e verificações de remanescentes | ✓ Testado e validado | Confirmação do responsável; o resumo anterior do Terraform informou 23 recursos destruídos |

A conciliação do faturamento permanece separada e depende de confirmação explícita. Não se deduzem dessas marcações tempo exato de failover, RTO/RPO, divisão de tráfego ou duração da sessão.

<a id="earlier-session-observations"></a>

### Observações das sessões anteriores

| Item | Origem da evidência | Resultado e limitação |
| --- | --- | --- |
| Plano inicial de implantação | O assistente inspecionou localmente o plano salvo gerado pelo responsável | 20 criações, sem alterações/exclusões/importações; escopo planejado restrito ao laboratório dev |
| Implantação inicial | O responsável relatou a criação | Os logs completos do apply não foram publicados nem revisados independentemente |
| Saúde inicial das VMs e do LB | O assistente executou duas consultas gcloud autorizadas e somente de leitura | Duas VMs RUNNING sem ações pendentes; dois backends HEALTHY naquele momento |
| Acesso inicial à página | O responsável confirmou o funcionamento da página | Não comprova observação dos dois tokens nem sucesso de failover/scaling |
| Limpeza inicial | O responsável confirmou explicitamente a conclusão | Não foi registrado inventário independente após a limpeza |
| Plano revisado | O assistente inspecionou localmente o plano salvo gerado pelo responsável | 23 criações: configuração básica mais Monitoring API e duas concessões de telemetria; presentes dispositivo de vídeo, inicialização do agente, utilização de 80%, snapshots US, agendamento no horário local e output de IP visível |
| Implantação revisada | O responsável relatou a conclusão | Instalação/ingestão do agente e outras configurações em execução não foram consultadas independentemente depois |
| Atualização da retenção para sete dias | Código validado estaticamente; o responsável relatou atualização bem-sucedida | Não foi demonstrado snapshot agendado nem restauração |
| Destruição final dos recursos | O responsável forneceu `Apply complete! Resources: 0 added, 0 changed, 23 destroyed` | Limpeza informada pelo Terraform, não comprovação independente de projeto vazio na nuvem |
| Inventário de snapshots | O responsável relatou ausência de snapshots após a consulta pela label da política | Nenhum snapshot correspondente informado; não é um inventário completo de snapshots manuais/sem label |

A Monitoring API permanece habilitada intencionalmente após o destroy. Os recursos do seed e seu estado de recuperação ficam fora da limpeza da aplicação. Logs/métricas armazenados, se ingeridos, e faturamento atrasado exigem conciliação separada. O último relato de gasto zero antes dos testes não deve ser apresentado como custo zero verificado após os testes. Os horários de início/fim não foram registrados de forma suficiente para comprovar cumprimento da janela de uma hora.

<a id="local-validation-history"></a>

## Histórico de validação local

- Revisão de bucket de estado/backend: passaram a validação de esquema Terraform, formatação, nove testes Python ativos, verificação de espaços e 268 verificações de links locais da documentação. Os hashes dos estados de seed e dev permaneceram iguais. Foram acrescentados planos simulados do bucket, mas não executados. Nenhum bucket foi provisionado, nenhum plan/apply foi executado e não houve migração de estado/backend. Remoção de versões, recuperação por soft delete e migração nos dois sentidos ainda exigem evidências do responsável.

- Consolidação do diretório da arquitetura: `terraform init -backend=false -lockfile=readonly` e `terraform validate` passaram no novo diretório. Os sete testes Python ativos passaram; os 21 testes do controlador descontinuado foram arquivados, e a verificação redundante de igualdade dos parâmetros do módulo foi removida. Formatação e 258 links locais passaram antes daquela atualização de evidências. Não houve plan/apply, plano simulado, operação em nuvem ou migração de estado.

- Revisão de projeto descartável/organização de arquivos: passaram 29 testes Python unitários/com simulação, validação Terraform da raiz/módulo, formatação, espaços e 251 links locais. Os hashes dos estados de dev e seed permaneceram iguais. Não houve plan/apply, operação em nuvem ou migração de estado. Os novos planos simulados de ciclo de vida do projeto continuam reservados ao responsável e não foram executados pelo assistente.

- Revisão de parâmetros configuráveis (2026-10-06): passaram a validação de esquema da raiz/módulo e os 27 testes Python unitários/com simulação. Os testes de contrato cobrem igualdade dos parâmetros e seu repasse entre raiz/módulo. Casos de planos simulados para parâmetros personalizados, HTTPS e combinações inválidas foram preparados, mas não executados. Não houve plan/apply nem ação em nuvem; não se alega resultado real de HTTPS, certificado ou DNS.
- Revisão exclusiva de produção (2026-10-06): o diretório de produção e o módulo compartilhado passaram em `terraform validate`; passaram formatação recursiva, espaços e 238 links locais. Os 23 testes Python unitários/com simulação passaram na mesma execução. Os cenários simulados do módulo passaram a aceitar prod e rejeitar dev, mas não foram executados. A inicialização dos providers usou `-backend=false`; não houve plan/apply, migração de backend, operação real no GCP, commit ou push. Os hashes de dev e seed permaneceram iguais. Uma busca limitada nos arquivos candidatos à publicação não encontrou IDs privados conhecidos nem cabeçalhos de chave privada; isso não é uma varredura completa de segredos.
- Reestruturação para projeto único: passaram validação de esquema da raiz/módulo de dev, formatação, espaços e 21 testes Python unitários/com simulação. Os testes históricos do controlador usam simulações; sua CLI está desativada.
- Revisão da página dos backends: dois testes adicionais de renderização/cabeçalho passaram separadamente. Não informe uma execução conjunta de 23 testes sem que ela tenha ocorrido.
- Revisão de dispositivo de vídeo/Ops Agent: raiz/módulo de dev validados após instalar o provider beta fixado; sintaxe Bash da inicialização, formatação e links locais passaram.
- Revisão da retenção de sete dias: passaram validação da raiz de dev, formatação e espaços.
- As suítes simuladas do módulo foram atualizadas, mas não executadas após o responsável reservar para si todos os planos Terraform, inclusive os comandos de plano simulado.

As declarações históricas de ausência de ações em nuvem se referem a reestruturações específicas, não às implantações posteriores executadas pelo responsável. As contagens de links são verificações daquele momento, não evidências do comportamento em nuvem.

<a id="evidence-and-administrative-follow-up"></a>

## Evidências e acompanhamento administrativo

- Anexe artefatos técnicos sem dados sensíveis para as categorias confirmadas quando estiverem disponíveis; não é necessário repetir testes apenas para acrescentar marcações.
- A confirmação independente dos resultados relatados continua indisponível; não apresente relatos do responsável como observações do assistente.
- Concilie o faturamento, incluindo telemetria retida e recursos do seed.
- Diferencie criação/restauração de snapshots da execução real do agendador diário, ainda não confirmada.
- Registre horários se for alegar cumprimento da janela de uma hora ou objetivos de recuperação medidos.
- Revise/retire separadamente o acesso temporário de bootstrap do seed até o prazo de revisão já definido, 2026-11-02.

Essa lista de atividades não implica nova implantação. Mantenha o limite acumulado de R$ 300 e a execução de plan/apply sob responsabilidade do operador.

<a id="related-documents"></a>

## Documentos relacionados

- [Cenário e arquitetura atuais](single-project-architecture.md)
- [Guia operacional e limpeza](../infra/README.md)
