<a id="adr-0011-one-production-project-for-the-landing-zone"></a>

# ADR 0011: um projeto de produção para a landing zone

- Situação: aceita
- Data: 2026-10-06
- Substitui: o destino dev da ADR 0009 e o escopo anterior de recursos em múltiplos projetos

<a id="context"></a>

## Contexto

O responsável quer que o case represente uma landing zone básica de produção em um projeto GCP existente antes da publicação. Os recursos anteriores de dev foram destruídos; seu estado local não contém recursos gerenciados. As evidências anteriores em execução pertencem a dev, não a produção. O seed foi aplicado separadamente e deve manter seu próprio gerenciamento e estado.

<a id="decision"></a>

## Decisão

Usar somente `infra/environments/prod` como diretório ativo da implantação naquele desenho. Fornecer o ID do projeto de produção existente por novos parâmetros privados; usar `prod` nos nomes e labels. Manter VPC/sub-rede, MIG privado em duas zonas, duas réplicas Nginx, scaling manual para três, LB HTTP global externo, endereços reservados de frontend/NAT, firewall, identidade de telemetria, Ops Agent e snapshots US com retenção de sete dias juntos nesse projeto.

Descontinuar o código dev como exemplo não executável e preservar estado, backups e parâmetros privados de dev nos locais originais. Não migrar/importar estado nem reutilizar planos salvos. Produção usa estado local próprio e planos novos revisados pelo responsável. Inspecionar metadados históricos do backend antes da inicialização; nunca forçar a cópia de estado de outro diretório.

Manter o histórico de seed/bootstrap separado; não implantar o bootstrap legado, renomear projetos nem excluir projetos existentes. Todos os planos, applies, planos simulados e destroys permanecem sob execução do responsável.

<a id="alternatives-considered"></a>

## Alternativas consideradas

- Manter dev e prod: escopo desnecessário para este case básico.
- Reclassificar evidências de dev ou mover seu estado para prod: enganoso e inseguro entre projetos.
- Implantar controles de fundação em toda a organização: pertence ao case separado de fundação corporativa.

<a id="consequences"></a>

## Consequências

A implantação e as verificações em execução de produção estão pendentes. Os testes anteriores de dev confirmados pelo responsável são somente evidências históricas. Verificar novamente APIs, permissões, cotas, faturamento e conflitos de nomes no projeto de destino antes do novo plano. O limite global de R$ 300 e a sessão de uma hora incluindo limpeza continuam válidos; esta reestruturação não autoriza novos recursos em nuvem.

<a id="trade-offs"></a>

## Compromissos e limitações

Um projeto simplifica a responsabilidade pelos recursos, mas não demonstra isolamento entre ambientes. É um cenário fictício de produção, não uma alegação de prontidão para produção: HTTP temporário, VMs pequenas, estado local, scaling manual e interrupção na substituição continuam sendo limitações explícitas do laboratório.
