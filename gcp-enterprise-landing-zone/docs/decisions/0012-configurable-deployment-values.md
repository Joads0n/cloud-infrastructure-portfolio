<a id="adr-0012-separate-deployment-values-from-resource-implementation"></a>

# ADR 0012: separar valores de implantação da implementação dos recursos

- Situação: aceita
- Data: 2026-10-06
- Atualização: a [ADR 0017](0017-responsibility-based-inputs.md) substitui a interface de variáveis soltas e settings por oito objetos. O texto abaixo preserva o desenho histórico.

<a id="context"></a>

## Contexto

O responsável quer permitir que outros usuários escolham IDs de projetos, nomes, localização, imagem, faixas de rede, capacidade e protocolos de frontend sem editar a implementação. O código anterior expunha apenas alguns valores; região, CIDR e diversos nomes estavam embutidos nos recursos/valores locais.

<a id="decision"></a>

## Decisão

Expor parâmetros tipados na raiz e um objeto settings validado, repassado sem alterações ao módulo local naquele desenho. Manter padrões fictícios nas declarações dos parâmetros e um exemplo completo de tfvars, não nos blocos de recursos. Nomes explícitos podem coexistir com nomes derivados de prefixo. Manter os nomes das VMs como base configurável do MIG, não como identidades fixas por instância.

Preservar a arquitetura de projeto único de produção e MIG privado em duas zonas, além de suas relações de segurança. Validar consistência entre região e zonas, CIDRs privados, nomes/hostname seguros, requisitos de frontend e limites de scaling atentos ao custo. Manter o contrato de imagem oficial Debian 12 com versão exata, pois a instalação na inicialização depende de Debian.

Permitir HTTP, HTTPS ou ambos no mesmo endereço global reservado. HTTP exige aceite explícito. HTTPS referencia certificados SSL globais existentes do Compute, termina TLS no LB e mantém backends HTTP privados; não são introduzidas chaves de certificados, gestão de DNS, certificados automáticos ou redirecionamentos.

<a id="alternatives-considered"></a>

## Alternativas consideradas

- Exigir edição de valores locais/blocos de recursos: mistura escolhas de implantação e implementação.
- Parametrizar todos os argumentos do provider: expõe invariantes de topologia/segurança sem requisito do case.
- Criar certificados e DNS: amplia ciclo de vida, responsabilidade por chaves/domínios e custos além desta alteração.
- Substituir o MIG por VMs nomeadas individualmente: perde a arquitetura de scaling acordada.

<a id="consequences"></a>

## Consequências

Os usuários editam tfvars privados e geram planos novos. Nesse desenho, os esquemas de settings da raiz e do módulo devem permanecer sincronizados; um teste unitário verifica a igualdade. Os endereços HTTP existentes recebem blocos moved explícitos para a indexação dos frontends opcionais. Não é realizada migração de estado/projeto.

O comportamento padrão permanece HTTP exclusivo com aceite explícito, duas réplicas pequenas e os padrões existentes de snapshots. Novos parâmetros e HTTPS exigem planos simulados executados pelo responsável e validação real; as evidências anteriores de dev não comprovam seus resultados. Disponibilidade, compatibilidade de imagem/certificado, cotas e custos ainda exigem revisão específica do projeto.

<a id="trade-offs"></a>

## Compromissos e limitações

Mais valores configuráveis exigem validação e documentação adicionais, mas não ampliam a arquitetura. Certificados existentes evitam armazenar chaves privadas neste estado, ao custo de um pré-requisito externo. HTTP/HTTPS simultâneos mantêm as requisições HTTP sem criptografia; não constituem uma política automática de obrigatoriedade de HTTPS. TLS termina no LB, não no Nginx.
