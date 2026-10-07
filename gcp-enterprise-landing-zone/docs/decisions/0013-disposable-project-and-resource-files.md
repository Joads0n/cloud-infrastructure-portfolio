<a id="adr-0013-disposable-project-lifecycle-and-responsibility-based-files"></a>

# ADR 0013: ciclo de vida de projeto descartável e arquivos por responsabilidade

- Situação: aceita
- Data: 2026-10-06
- Substitui: a restrição a projeto existente da ADR 0011

<a id="context"></a>

## Contexto

O responsável quer que o avaliador implante a landing zone completa, incluindo criação de projeto, vínculo de faturamento, labels e APIs, em um único fluxo. Ele escolheu explicitamente destruir tanto os recursos quanto o projeto criado. Projetos existentes do laboratório pessoal continuam úteis para testes, mas não devem ser assumidos nem excluídos. Os valores já estão separados da implementação; arquivos de implementação grandes dificultam a análise.

<a id="decision"></a>

## Decisão

Usar `create_project=true` como padrão. Criar um projeto com conta de faturamento existente, organização/pasta existente opcional, labels, sem rede padrão e com `deletion_policy="DELETE"`. Habilitar as APIs antes da identidade/IAM de execução e dos recursos da aplicação. Manter o estado local único fora do projeto em nuvem para que permaneça disponível durante a desmontagem.

Fornecer o modo explícito de teste `create_project=false`. Nesse modo, não criar recurso de projeto, alterar faturamento/hierarquia/labels nem assumir APIs básicas gerenciadas pelo seed. Preservar a habilitação de Monitoring e exigir que as demais APIs básicas já existam. Rejeitar parâmetros de faturamento e hierarquia no modo de projeto existente.

Organizar a implementação por responsabilidade: projeto, APIs, conta de serviço, IAM, VPC/sub-rede, NAT, firewall, template de VM, MIG, LB e snapshots. Manter um ponto de execução e um exemplo de tfvars. Recursos relacionados podem compartilhar um arquivo; a ordem dos arquivos não controla dependências.

<a id="alternatives-considered"></a>

## Alternativas consideradas

- Sempre exigir projeto existente: não demonstra a landing zone completa.
- Exigir applies separados de seed/bootstrap para avaliadores: adiciona etapas operacionais desnecessárias.
- Manter projetos criados após destroy: contraria o ciclo de vida descartável escolhido.
- Importar projetos existentes para o novo recurso: arrisca excluir ativos preexistentes do usuário.
- Um arquivo por regra de firewall/componente de LB: acrescenta fragmentação sem melhorar a separação de responsabilidades.

<a id="consequences"></a>

## Consequências

O usuário ainda precisa de credenciais, permissões de criação/exclusão de projeto e vínculo de faturamento, cotas disponíveis e contexto operacional de APIs/cotas. O Terraform não pode criar a conta do usuário, sua conta de faturamento, a organização ou a autenticação inicial. O avaliador deve substituir os IDs fictícios e a imagem de exemplo.

Um apply revisado provisiona os recursos conforme as dependências; um destroy normal confirmado remove os recursos gerenciados e solicita a exclusão do projeto por último. Não colocar recursos alheios ao laboratório em um projeto descartável. Nunca trocar o modo de ciclo de vida ou o ID do projeto em um estado que gerencie recursos. Os parâmetros do modo de projeto existente devem ser explícitos nos testes do laboratório.

A desativação do projeto segue o [ciclo de recuperação do GCP](https://docs.cloud.google.com/resource-manager/docs/delete-restore-projects?hl=en); não é apagamento definitivo imediato. Conciliar faturamento atrasado e recursos remanescentes. Os estados existentes de seed e dev permanecem intactos, e suas evidências não comprovam este novo fluxo.

<a id="trade-offs"></a>

## Compromissos e limitações

A exclusão automática do projeto simplifica a limpeza, mas também exclui recursos adicionados fora do Terraform dentro dele. O modo de projeto existente é menos autossuficiente, porém preserva o gerenciamento anterior de APIs/estado. As APIs não são desabilitadas durante a desmontagem, permitindo destruir recursos dependentes antes do projeto; Monitoring permanece habilitado no projeto existente. Arquivos separados melhoram a legibilidade sem acrescentar módulos ou applies separados.
