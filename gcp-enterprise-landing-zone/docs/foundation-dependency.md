<a id="foundation-and-workload-boundaries"></a>

# Limites entre fundação e recursos da aplicação

Modelo histórico de dependências, substituído pela [ADR 0009](decisions/0009-single-project-owner-operated-lab.md) e pelo escopo exclusivo de produção da [ADR 0011](decisions/0011-single-production-project.md). A configuração ativa de produção usa ADC do usuário, cria sua conta de execução e começa com estado local. Não exige apply do bootstrap.

A [Landing Zone](../README.md) reúne o cenário fictício completo, mas, no desenho histórico abaixo, mantém quatro diretórios Terraform separados. O seed gerencia APIs, a identidade temporária de bootstrap e suas permissões. O bootstrap gerencia identidades por ambiente, buckets de estado e roteamento de auditoria. Os diretórios dev e prod gerenciam, cada um, rede, firewall, NAT, LB e computação de sua aplicação. Consuma outputs de bootstrap revisados como parâmetros privados; não duplique responsabilidades nem una estados.

<a id="operating-paths"></a>

## Caminhos operacionais

No fluxo histórico, execute comandos dos recursos a partir de `gcp-enterprise-landing-zone/`. A versão compartilhada da CLI fica em `../.terraform-version`; o binário privado fica em `../.private/tools/terraform/1.16.5/terraform`. Parâmetros privados e o registro financeiro acumulado único permanecem em `.private/`, na raiz do repositório.

Antes de qualquer sessão futura daquele fluxo, revise os caminhos na configuração privada, use caminhos absolutos para parâmetros privados e registro financeiro compartilhado e gere um plano novo revisado. Nunca reinicie o registro financeiro nem reutilize planos anteriores à movimentação. Novos comprovantes do controlador ficam no diretório `.private/` ignorado deste case. Comprovantes históricos são evidências, não instruções para retomar caminhos antigos.

O [plano de validação](proposals/gcp-landing-zone-validation.md) cobre a aceitação da fundação e dos recursos. Naquele registro, somente o seed havia sido aplicado. A consolidação ali descrita não alterava endereços de recursos Terraform, backend, identidade de provider ou recursos em nuvem; a implantação continuava sujeita a autorização separada.
