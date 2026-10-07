<a id="vm-web-platform--terraform-entry-point"></a>

# Plataforma web em VMs — ponto de execução do Terraform

Execute todos os comandos Terraform a partir deste diretório. Ele reúne a preparação do projeto e a implementação dos recursos; não há módulo filho nem seleção por diretório de ambiente.

Após o apply, aguarde aproximadamente **2 a 5 minutos** antes de acessar a página pelo IP exibido em `lb_ip`. A inicialização das VMs e as verificações de integridade do LB podem continuar após o Terraform concluir. O intervalo é estimado; confirme os backends saudáveis e a resposta HTTP seguindo o [guia operacional](../README.md#planned-runtime-checks), sem ultrapassar os limites da sessão.

O estado permanece local durante todo o ciclo de vida. Este diretório não cria bucket e não oferece migração para GCS. Use init, plan, apply e destroy com o mesmo arquivo privado de parâmetros e preserve backups independentes. Nunca exclua o estado para contornar erros. Consulte a [ADR 0018](../../docs/decisions/0018-local-state-only.md).

- Valores: [terraform.tfvars.example](terraform.tfvars.example), copiado para um arquivo privado ignorado pelo Git.
- Implementação: projeto, APIs, identidade/IAM, rede, NAT, firewall, template de VM, MIG, balanceadores e snapshots, em arquivos separados por responsabilidade.
- Conteúdo das VMs: [templates/](templates).
- Testes Terraform: [tests/](tests), com planos simulados executados somente pelo responsável.
- Testes Python: [../../tests/](../../tests), ao lado de infra, não dentro deste diretório.
- Execução e limpeza: [guia operacional](../README.md).

Por padrão, a configuração cria um projeto de produção descartável. O destroy solicita a exclusão do projeto após remover os recursos. Para testes em projeto existente, defina explicitamente `project_settings.create_project=false` e deixe os parâmetros de faturamento e hierarquia como null.

<a id="state-boundary-after-consolidation"></a>

## Separação dos estados após a consolidação

Nenhum estado de produção foi encontrado no diretório antigo durante a consolidação. Seu cache de providers não foi migrado. O estado de seed, o estado vazio de dev e seus backups foram movidos sem alteração para a recuperação privada fora deste case, conforme a [ADR 0016](../../docs/decisions/0016-private-legacy-recovery.md). Nunca copie esses estados para este diretório.

`migrations.tf` registra as alterações de endereço dos recursos em relação à estrutura de produção imediatamente anterior, baseada em módulo; ele não move arquivos de estado. Quem já implantou aquela estrutura deve interromper o uso do novo diretório até revisar explicitamente a migração de backend/estado e proteger uma cópia de recuperação. Não inicialize um estado novo sobre recursos existentes, não troque de projeto e não execute planos antigos salvos.

Uma nova avaliação começa aqui, com parâmetros privados novos e um plano recém-revisado. A consolidação dos diretórios não executou plan/apply e não constitui evidência de implantação.
