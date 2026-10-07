<a id="adr-0014-one-architecture-named-root-without-a-child-module"></a>

# ADR 0014: diretório único nomeado pela arquitetura, sem módulo filho

- Situação: aceita
- Data: 2026-10-06
- Refina: ADRs 0012 e 0013
- Atualização em 2026-10-07: a [ADR 0016](0016-private-legacy-recovery.md) substitui a decisão de manter legacy público e os estados nos caminhos antigos. Os trechos abaixo registram a decisão original.

<a id="context"></a>

## Contexto

O responsável quer um diretório nomeado pela arquitetura, independente do ID do projeto, nome da empresa ou label de ambiente escolhidos pelo avaliador. Existe uma implementação, sem reutilização demonstrada que exija a separação atual entre raiz e módulo. O controlador descontinuado e testes históricos não relacionados desviam o foco da avaliação. Os testes Python devem permanecer ao lado de infra.

<a id="decision"></a>

## Decisão

Consolidar a preparação do projeto e seus recursos em `infra/vm-web-platform/`. Manter um modelo de valores chamado `terraform.tfvars.example`, um contrato único de parâmetros, arquivos de recursos por responsabilidade e o conteúdo das VMs em `templates/`. Remover o módulo filho e as pastas ativas de ambiente/controlador.

Manter os planos Terraform simulados em `tests/` dentro desse diretório. Manter os testes Python relevantes em `tests/` no nível do case, ao lado de `infra/`. Remover verificações redundantes de igualdade de parâmetros e arquivar os testes do controlador junto com ele.

Arquivar os artefatos públicos de seed/bootstrap/dev/prod/controlador em `legacy/`, com extensões de código não executáveis. Preservar estado, arquivos de recuperação e metadados de backend inicializado, ignorados pelo Git, nos locais antigos. Não havia estado de produção.

Acrescentar blocos moved explícitos mapeando os recursos do módulo imediatamente anterior para a raiz. Preservar a ordem anterior de API/IAM por dependências explícitas nos recursos da aplicação. Não mover nem importar estado automaticamente.

<a id="alternatives-considered"></a>

## Alternativas consideradas

- Diretório nomeado pelo projeto/empresa: vincula a organização de arquivos aos valores do avaliador.
- Diretório nomeado pelo ambiente: não identifica uma arquitetura.
- Manter módulo de uso único: duplica parâmetros e exige navegação desnecessária.
- Excluir o material legado de seed: perde contexto de manutenção de recursos aplicados.

<a id="consequences"></a>

## Consequências

A avaliação usa um diretório raiz e estado local independente. São necessários planos novos. Os blocos moved só se aplicam após associar deliberadamente o estado de uma implantação existente ao novo diretório por migração revisada separadamente; não são instruções para copiar estados de dev/seed. Implantações existentes não devem começar aqui com estado novo e vazio.

Registros históricos e contagens de testes continuam identificados como histórico. Novas suítes de planos simulados e implantação real permanecem sob execução do responsável. A consolidação não retira privilégios existentes do seed nem altera o orçamento acumulado ou os limites da sessão.

<a id="trade-offs"></a>

## Compromissos e limitações

O diretório raiz fica maior, mas os arquivos permanecem agrupados por responsabilidade. Menos intermediação e um único conjunto de variáveis facilitam a análise, ao custo de não haver módulo reutilizável da aplicação. Remanescentes locais legados, ignorados pelo Git, são mantidos para recuperação, embora não apareçam em um clone novo.
