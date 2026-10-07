<a id="adr-0015-landing-zone-state-bucket-and-staged-gcs-backend"></a>

# ADR 0015: bucket de estado da landing zone e backend GCS em etapas

- Situação: substituída pela [ADR 0018](0018-local-state-only.md)

Este documento preserva uma decisão histórica. Bucket, exemplos GCS e migração foram retirados da implementação atual; não siga o fluxo abaixo para novas avaliações.
- Data: 2026-10-06

<a id="context"></a>

## Contexto

O responsável solicita um bucket de estado multirregional US, com versionamento, remoção de versões por ciclo de vida para manter cinco versões e soft delete, além de um exemplo de backend ativado somente após criar projeto/bucket. O mesmo diretório de recursos descartáveis gerencia o projeto; hospedar o próprio estado introduz dependências na preparação inicial e na desmontagem.

<a id="decision"></a>

## Decisão

Refinamento do responsável: política de armazenamento e prefixo do backend são valores fixos da implementação, não parâmetros tfvars. O nome do bucket segue `bucket-iac-state-<project_id>`, e somente esse nome resolvido é informado privadamente ao backend. A proteção contra exclusão fica fixa em `force_destroy=false`; a alteração de código documentada, exclusiva para limpeza, substitui a interface anterior de variável descrita abaixo.

Criar um bucket GCS Standard dedicado e privado no projeto da landing zone. Habilitar versionamento, soft delete de sete dias, acesso uniforme no nível do bucket e prevenção de acesso público. Excluir gerações arquivadas do estado com cinco versões mais novas; interpretar cinco como a geração atual mais quatro anteriores. O ciclo de vida é assíncrono, e cópias com soft delete permanecem retidas temporariamente.

Manter `backend.tf` local no primeiro apply. Fornecer `backend.tf.example` com um bloco GCS parcial e comentário explícito de uso somente na segunda inicialização. Na decisão original, bucket/prefixo eram fornecidos por configuração privada ignorada pelo Git; o refinamento acima fixa o prefixo e mantém somente o nome do bucket como entrada privada. Retirar o bloco local de versions.tf para que a ativação não introduza acidentalmente declarações duplicadas de backend.

Antes da limpeza completa, migrar o estado de volta para local com backup independente. Recusar a destruição de bucket não vazio por padrão. Na interface original, após verificação, o responsável podia aplicar explicitamente `state_bucket_force_destroy=true` e realizar a limpeza; o refinamento acima substitui essa variável pela alteração temporária de código documentada. A identidade da VM não recebe acesso ao estado.

<a id="alternatives-considered"></a>

## Alternativas consideradas

- Ativar GCS no primeiro init: impossível antes de o bucket existir.
- Reter todas as gerações indefinidamente: não atende à remoção de versões por ciclo de vida.
- Manter cinco versões arquivadas mais uma atual: excede a interpretação escolhida de cinco no total.
- Projeto/diretório de gerenciamento separado: oferece ciclo de vida do estado mais independente, mas amplia o case simplificado.
- Forçar incondicionalmente a exclusão do bucket: arrisca destruir o backend ativo.

<a id="consequences"></a>

## Consequências

A avaliação passa a incluir migração de backend, e a desmontagem com estado no GCS exige primeiro a migração de volta. Não é necessário um segundo apply apenas para migrar. Identificadores de bucket e faturamento permanecem privados. O gerenciamento inicial de APIs inclui Storage somente no modo de criação; testes em projeto existente precisam tê-la habilitada.

A destruição do projeto continua seguindo o ciclo de vida descartável escolhido, mas a migração do estado remoto e o consentimento explícito para excluir o bucket passam a ser pré-requisitos. Soft delete não substitui backup independente nem elimina obrigações de conciliação de custos remanescentes.

<a id="trade-offs"></a>

## Compromissos e limitações

Hospedar o próprio estado é uma solução compacta, mas vinculada ao ciclo de vida do projeto. A retenção de cinco versões limita o histórico normal do estado, não imediatamente todas as gerações armazenadas nem as cópias com soft delete. A recuperação por sete dias ultrapassa intencionalmente a curta sessão de testes de computação. Não se alega migração ou limpeza em nuvem sem evidências do responsável.
