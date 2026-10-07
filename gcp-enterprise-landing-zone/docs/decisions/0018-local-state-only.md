# ADR 0018: estado local sem bucket na Landing Zone

- Situação: aceita pelo responsável
- Data: 2026-10-07
- Substitui: [ADR 0015](0015-landing-zone-state-bucket.md)

## Contexto

O laboratório é descartável, operado por uma pessoa e limitado a sessões curtas. Gerenciar o bucket que armazena o próprio estado exigia inicialização em etapas e migração de volta antes da limpeza. Na execução anterior, o bucket foi excluído enquanto ainda era o backend ativo, impedindo a persistência do estado final; o Terraform preservou um arquivo local de recuperação. O responsável solicitou retirar esse fluxo para simplificar a avaliação.

## Decisão

Usar o backend local durante todo o ciclo de vida: init, plan, apply e destroy. Retirar o recurso do bucket, seu output, exemplos GCS, testes específicos e instruções de migração. Retirar a habilitação explícita da Storage API, que servia somente a esse recurso. Manter snapshots de discos, que são recursos Compute independentes do bucket retirado.

O Terraform continua exigindo estado. Preservar os arquivos locais e backups privados, ignorados pelo Git, em armazenamento protegido. Um único operador executa as operações; não há compartilhamento de estado entre estações. Nenhum estado ou backup é excluído por esta mudança de código.

## Alternativas consideradas

- Bucket no próprio projeto: exige coordenar a remoção do backend ativo, aumentando o risco durante a limpeza.
- Backend remoto em projeto de gerenciamento separado: adequado a colaboração e governança mais robustas, mas acrescenta preparação e retenção fora do escopo deste case.
- Excluir ou dispensar o estado: não é uma opção segura de gerenciamento Terraform.

## Consequências

O avaliador não precisa de permissões de administração de Storage para este case, configuração tfbackend, migração ou alteração temporária de force_destroy. Pode destruir diretamente os recursos com o mesmo arquivo de parâmetros e estado usados na criação. O modo de projeto descartável continua solicitando a exclusão do projeto; não altera o ciclo de vida de projetos existentes.

Quem ainda usa a versão antiga com GCS deve interromper a implantação e revisar a recuperação antes de adotar esta versão. Não executar init com estado vazio sobre recursos existentes, não apagar .terraform para contornar erros e não reutilizar planos anteriores. Alterar backend.tf não modifica sozinho o backend inicializado. A retirada de código não remove recursos de uma implantação antiga automaticamente.

## Compromissos e limitações

O fluxo fica mais simples, mas depende da proteção e dos backups da estação. Não oferece armazenamento central, histórico de objetos nem coordenação entre operadores. Estado vazio não substitui inventário de resíduos ou conciliação de faturamento. As retenções de snapshots e a recuperação do projeto continuam independentes do estado local.
