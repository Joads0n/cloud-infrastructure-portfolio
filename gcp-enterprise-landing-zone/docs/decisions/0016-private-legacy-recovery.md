# ADR 0016: retirada dos diretórios legados da entrega pública

- Situação: aceita pelo responsável
- Data: 2026-10-07
- Refina: [ADR 0014](0014-single-architecture-root.md)

## Contexto

A consolidação manteve código histórico em legacy e diretórios locais antigos com estados, backups e caches. Essa estrutura confundia a leitura do case, cuja única implementação ativa está em infra/vm-web-platform.

## Decisão

Retirar legacy, scripts, infra/seed, infra/bootstrap, infra/environments, infra/modules e os diretórios históricos tests/seed e tests/bootstrap da Landing Zone. Preservar integralmente seu conteúdo em uma pasta de recuperação sob .private/recovery, na raiz do repositório, ignorada pelo Git e fora da entrega pública. O índice privado registra a origem dos arquivos e os hashes dos estados e do backup de desenvolvimento.

Manter os documentos de decisões e propostas como registros históricos, sem links para os arquivos retirados e sem apresentá-los como instruções de implantação atual. Os registros detalhados do seed permanecem na recuperação privada; não há nova validação em nuvem nesta limpeza.

## Alternativas consideradas

- Manter legacy público: preserva acesso imediato ao código antigo, mas mantém a ambiguidade para o avaliador.
- Excluir definitivamente todos os arquivos: descartado porque o seed possui estado aplicado e exige recuperação e manutenção independentes.

## Consequências

A única raiz Terraform permanece infra/vm-web-platform; os testes Python ativos continuam ao lado de infra. Os hashes dos estados e do backup foram preservados. Nenhum recurso GCP foi criado ou removido e nenhum privilégio do seed foi revogado. A movimentação de arquivos não é migração de backend Terraform.

Antes de manutenção do seed, o responsável deve recuperar e revisar o contexto original, inclusive caminhos, backend, credenciais e configuração. Não executar Terraform na pasta de recuperação, reutilizar planos antigos ou copiar estados históricos para a raiz ativa. A revisão do seed permanece separada, com prazo histórico de 2026-11-02.

## Compromissos e limitações

O avaliador recebe uma estrutura mais simples, mas deixa de acessar diretamente o código antigo. A recuperação local é reversível; não substitui backup independente nem comprova restauração. As propostas e os ADRs anteriores descrevem decisões de suas respectivas datas, não a estrutura atual.
