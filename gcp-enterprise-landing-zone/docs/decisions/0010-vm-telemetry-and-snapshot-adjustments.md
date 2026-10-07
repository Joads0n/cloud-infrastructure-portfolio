<a id="0010-vm-diagnostics-telemetry-lb-target-and-snapshot-window"></a>

# 0010: diagnóstico das VMs, telemetria, meta do LB e janela de snapshots

Situação: implementado na configuração; plan/apply e validação em execução continuam sob responsabilidade do operador. O MIG atual não aceita proteção contra exclusão por VM, e ela não foi implementada.

<a id="context"></a>

## Contexto

Após o primeiro teste da aplicação, o responsável solicitou proteção contra exclusão das VMs, dispositivos de vídeo, instalação do Ops Agent, utilização-alvo de 80% nos backends, snapshots multirregionais US, agendamento diário entre 02:00 e 03:00 e exibição do IP do LB. Posteriormente, confirmou a limpeza do primeiro teste, uma implantação revisada, a aplicação da retenção de sete dias dos snapshots e a remoção final de 23 recursos. Consulte o [registro de evidências](../single-project-validation.md) para identificar a origem dos relatos e as verificações em execução ainda não confirmadas.

<a id="decision"></a>

## Decisão

- Manter o MIG: o Google não oferece proteção contra exclusão por VM em instâncias gerenciadas nem em templates de instância. Não substituí-la por `prevent_destroy` do Terraform alegando proteção equivalente. Mudar para VMs independentes/não gerenciadas exige aprovação do responsável e outro desenho de scaling.
- Habilitar o dispositivo de vídeo do template com `hashicorp/google-beta` fixado em 8.5.0 somente para o template; o provider estável nessa versão rejeita `enable_display`. Os demais recursos mantêm `google`. Isso não instala ambiente gráfico, não abre portas de área de trabalho remota nem habilita o console serial. O responsável deve inicializar o novo provider antes de gerar o plano.
- Instalar o Ops Agent pelo instalador HTTPS do Google durante a inicialização da VM, após configurar o Nginx. A instalação existente do pacote é detectada nas reinicializações. É uma instalação de preparação inicial, não uma imagem pré-configurada nem garantia de disponibilidade imediata do agente na criação da VM. Usar o pacote atual do repositório; não se alega reprodutibilidade exata da versão do pacote.
- Conceder à conta de execução somente Logs Writer e Monitoring Metric Writer por membros IAM aditivos. A Monitoring API é gerenciada por esta configuração com `disable_on_destroy=false`; a Logging API permanece sob responsabilidade do seed nesse desenho. Não duplicar o gerenciamento das APIs existentes. Se Monitoring já for gerenciado por outro estado, interromper para revisão antes do apply.
- Definir `max_utilization=0.8` com balanceamento UTILIZATION. É uma meta de balanceamento, não autoscaling nem limite rígido de CPU. Manter `capacity_scaler=1` e scaling manual 2 → 3 → 2.
- Armazenar os snapshots agendados em `us`. Considerar que a janela 02:00–03:00 informada pelo usuário corresponde a America/Fortaleza (UTC−03); configurar 05:00 UTC. O GCP inicia dentro daquela hora, não necessariamente no minuto exato; a conclusão antes de 03:00 não é garantida. O responsável solicitou posteriormente retenção de sete dias em 2026-10-06, substituindo o valor inicial de um dia; manter `APPLY_RETENTION_POLICY` na exclusão da origem. O responsável relatou aplicar a atualização antes da destruição final; nenhum snapshot agendado ou restauração foi observado. Os custos de snapshots podem continuar após a sessão das VMs descartáveis.
- Acrescentar outputs Terraform `lb_ip` não marcados como sensíveis no módulo e na raiz, para mostrar o IPv4 público reservado após o apply. Manter o output de endpoint existente como sensível. A exibição é intencional, mas o endereço deve ser removido das evidências públicas.

O responsável posteriormente recusou a mudança para MIG stateful apenas para preservar discos. Manter `auto_delete = true` no disco de inicialização; a retenção de sete dias dos snapshots tem ciclo de vida separado. Essa decisão não habilita proteção contra exclusão de VM nem preserva os discos de inicialização de VMs excluídas.

<a id="alternatives-considered"></a>

## Alternativas consideradas

- VMs independentes com proteção contra exclusão: alternativa possível, mas altera o ciclo de vida do grupo gerenciado e o desenho de scaling aceitos.
- `prevent_destroy` no MIG: protege somente contra destruição pelo Terraform, não contra redução de capacidade ou operações diretas na API; não foi adotado silenciosamente como substituto.
- Imagem com Ops Agent pré-instalado ou distribuição por políticas do sistema operacional: adicionam mecanismos além do necessário para este laboratório baseado em inicialização; não foram introduzidos.
- Snapshots às 02:00 UTC: resultam em outra janela local; usar a interpretação de Fortaleza, salvo correção do responsável.

<a id="consequences"></a>

## Consequências

Mudanças no template podem substituir VMs em execução pela política proativa existente e interromper o serviço. Não reutilizar planos de implantação salvos. Se a primeira sessão ainda estiver ativa, concluir sua limpeza no prazo original, em vez de estendê-la para implantar esta revisão. O assistente não executa novo plan/apply.

Revisar as permissões adicionais de IAM do projeto e Service Usage exigidas pelo operador humano. A telemetria pode gerar custos de ingestão/armazenamento e consumir memória nas VMs e2-micro. Verificar Nginx, os dois subagentes do Ops Agent e os logs/métricas reais separadamente: a saúde do LB, sozinha, não comprova o funcionamento da telemetria. O log de acesso do Nginx permanece desabilitado; trata-se da telemetria padrão do sistema, não de uma integração personalizada de observabilidade do Nginx.

O destroy remove as concessões de telemetria e a identidade de execução, mas mantém intencionalmente a Monitoring API habilitada. Snapshots gerados e telemetria armazenada sobrevivem à destruição dos recursos conforme suas retenções próprias; conciliar custos remanescentes dentro do limite acumulado de R$ 300. A restrição de uma hora para a sessão descartável permanece inalterada.

<a id="trade-offs"></a>

## Compromissos e limitações

A instalação na inicialização mantém o laboratório simples, mas depende de repositórios/NAT e demora mais que uma imagem pré-configurada. A telemetria acrescenta diagnóstico e também custos e permissões IAM. O armazenamento multirregional US é uma escolha de localização de backup, não evidência de recuperação regional de desastres testada. Manter o MIG preserva o comportamento de scaling, mas não atende à proteção contra exclusão por VM.

<a id="references"></a>

## Referências

- [Limitações da proteção contra exclusão](https://docs.cloud.google.com/compute/docs/instances/preventing-accidental-vm-deletion)
- [Instalação do Ops Agent](https://docs.cloud.google.com/logging/docs/agent/ops-agent/installation)
- [Horários dos agendamentos de snapshots](https://docs.cloud.google.com/compute/docs/disks/about-snapshot-schedules)
