# ADR 0017: objetos de entrada separados por responsabilidade

- Situação: aceita pelo responsável
- Data: 2026-10-07
- Refina: [ADR 0012](0012-configurable-deployment-values.md)
- Atualização posterior: a [ADR 0018](0018-local-state-only.md) retira o bucket e os exemplos GCS; referências a eles abaixo descrevem a configuração anterior.

## Contexto

A interface combinava variáveis soltas de projeto, imagem, réplicas e exposição com um objeto settings genérico. A ordem visual dificultava entender quais valores pertenciam a cada recurso. O responsável escolheu organizar os parâmetros por responsabilidade antes do teste ponta a ponta.

## Decisão

Declarar oito objetos tipados em variables.tf: project_settings, deployment_settings, network_settings, compute_settings, application_settings, load_balancer_settings, snapshot_settings e identity_settings. Incorporar o conteúdo de settings.tf ao contrato único e retirar a interface antiga. O tfvars continua sendo um único arquivo privado, com um bloco por objeto; os arquivos de implementação continuam separados por recurso/responsabilidade.

Refinamento solicitado pelo responsável: região, prefixo e ambiente ficam em deployment_settings; as zonas pertencem exclusivamente a compute_settings, validadas contra a região. Não há labels configuráveis em deployment_settings nem herança entre recursos. Projeto, VMs e snapshots possuem seus próprios mapas, vazios por padrão; null equivale ao mapa vazio. Todos recebem as labels automáticas de ambiente e gerenciamento, e snapshots também recebem backup_policy. O bucket mantém apenas as labels automáticas, seguindo sua configuração fixa. O modo de projeto existente não gerencia suas labels. Hostname fica em application_settings, compartilhado por Nginx e HTTPS.

Manter os valores padrão, as validações de segurança, os endereços Terraform, as dependências e os controles de rede. A política do bucket e o prefixo GCS continuam fixos. Esta mudança de interface não exige módulos novos nem migração de estado.

## Alternativas consideradas

- Agrupar somente por comentários: não resolve a interface genérica na implementação.
- Um settings com objetos internos: organiza os campos, mas mantém um contêiner único e referências mais longas.
- Manter simultaneamente as duas interfaces: aumenta a ambiguidade de precedência e os testes necessários.

## Consequências

Arquivos privados antigos precisam ser convertidos com backup e conferência dos valores. project_settings exige project_id; compute_settings exige image. Não reutilizar planos salvos. Ao escalar, editar backend_count dentro de compute_settings no arquivo privado completo; uma sobrescrita parcial do objeto não mescla seus atributos.

As suítes simuladas acompanham a nova interface, preservando cenários positivos e negativos. Não houve apply, importação, migração de backend ou alteração de recursos GCP nesta reorganização. Um plano real novo continua obrigatório antes de qualquer implantação.

## Compromissos e limitações

Há mais blocos no arquivo, mas cada responsabilidade fica explícita. A interface é incompatível com os nomes antigos; isso é preferível a manter duas fontes de configuração. A preservação textual dos valores e testes simulados não substituem a revisão de um plano real nem a validação em nuvem.
