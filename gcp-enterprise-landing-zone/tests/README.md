<a id="tests-for-the-vm-web-platform"></a>

# Testes da plataforma web em VMs

Os testes Python ficam aqui, ao lado de `infra/`. Os testes Terraform ficam no [diretório único da arquitetura](../infra/vm-web-platform/README.md). São ferramentas opcionais de avaliação, não etapas de provisionamento.

<a id="python-checks--no-cloud-or-terraform-plans"></a>

## Verificações Python — sem nuvem nem planos Terraform

Na raiz do repositório:

```sh
python3 -m unittest discover -s gcp-enterprise-landing-zone/tests -v
```

Os onze testes Python ativos verificam:

- Renderização da identidade e da cor dos backends, persistência da identificação e configuração do cabeçalho contra cache.
- Repasse dos parâmetros aos providers e à identidade, além da ausência de valores de implantação conhecidos fixos na lógica.
- Repasse independente das labels do projeto, VMs e snapshots; sem herança configurável.
- Contrato de oito objetos por responsabilidade, sem a interface genérica antiga.
- Responsabilidade explícita pelo ciclo de vida do projeto.
- Separação dos arquivos por responsabilidade, sem módulo filho.
- Declarações de dependência dos recursos Compute e mapeamentos de endereços do módulo para o diretório raiz.
- Uso exclusivo do backend local e ausência de bucket, exemplos GCS e habilitação da Storage API.

São verificações textuais e de renderização dos contratos do código, não um interpretador Terraform nem comprovação do comportamento na nuvem. O teste redundante de igualdade dos parâmetros entre raiz e módulo foi removido. Os 21 testes do controlador foram retirados da entrega pública e preservados na recuperação privada ([ADR 0016](../docs/decisions/0016-private-legacy-recovery.md)); não os inclua nas alegações de cobertura atual.

## Tabela dos testes Python

Os nomes dos testes abaixo correspondem às funções em [test_backend_page.py](test_backend_page.py), [test_configuration_contract.py](test_configuration_contract.py) e [test_state_backend.py](test_state_backend.py). A terceira coluna descreve o critério de aprovação, não valores observados na nuvem.

| Teste | O que verifica localmente | Resultado esperado para aprovação |
| --- | --- | --- |
| `test_distinct_replicas_have_visible_identity` | Renderização textual da identidade e da cor com tokens fictícios | 3 páginas distintas; cada uma contém seu identificador e a cor dos 6 primeiros caracteres do token; nenhum marcador __BACKEND_ pendente. |
| `test_server_identity_and_no_cache_are_preserved` | Trechos do script de inicialização, sem executar Nginx | Condição de preservação do token, cabeçalhos X-Lab-Backend e Cache-Control no-store e substituição da cor presentes no código. |
| `test_compute_resources_keep_dependencies_and_address_mappings` | Declarações de dependências e mapeamentos dos recursos Compute | Para cada recurso Compute examinado, referências às APIs e ao IAM de telemetria no arquivo e mapeamentos from/to correspondentes; nenhuma migração é executada. |
| `test_independent_project_and_vm_labels` | Referências das labels e das zonas | Projeto usa local.project_labels; VM usa local.vm_labels; zonas usam compute_settings.zones; snapshots usam seu próprio mapa; nenhuma referência a deployment_settings.labels em locals.tf. |
| `test_inputs_are_grouped_by_responsibility` | Contrato de parâmetros e orientação de scaling | Exatamente os 8 objetos previstos; ausência de var.settings e do argumento antigo de backend_count no guia operacional. |
| `test_project_ownership_is_explicit` | Expressões de gerenciamento do projeto | count condicionado a create_project, deletion_policy DELETE e alternativa de uso do ID existente presentes. |
| `test_resource_groups_have_separate_files` | Separação da implementação | Declarações de recursos nos 7 arquivos examinados: network, nat, firewall, vm, mig, load-balancers e snapshots; nenhum bloco de módulo filho. |
| `test_resource_logic_has_no_case_specific_deployment_literals` | Lista limitada de valores que não devem estar fixos nos recursos | Nenhuma ocorrência dos literais pesquisados: prefixo crl-, us-central1, 10.80.10.0/24, app.cedar-route.example, e2-micro e pd-standard nos arquivos examinados. |
| `test_root_passes_configuration_and_region` | Repasse de região e identidade | 2 referências à região configurável nos providers e referência a identity_settings.runtime_service_account_id na conta de serviço. |
| `test_lifecycle_has_only_local_backend` | Declaração de backend e exemplos retirados | Exatamente 1 declaração explícita local; ausência de backend.tf.example e state.tfbackend.example. |
| `test_no_remote_state_infrastructure` | Ausência da infraestrutura de estado remoto | Nenhum google_storage_bucket, output state_bucket_name ou habilitação explícita de storage.googleapis.com; arquivo state-bucket.tf ausente. |

Resultado local após a retirada do bucket: **11 testes aprovados**. Esses testes não verificam cotas, IAM efetivo, saúde real do LB, instalação dos agentes, execução de snapshots, restauração de dados ou limpeza na nuvem.

<a id="terraform-checks--owner-executed"></a>

## Verificações Terraform — executadas pelo responsável

Após a inicialização, na raiz do repositório:

```sh
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform fmt -check
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform validate
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform test
```

O último comando executa planos simulados, não applies. Todas as suítes simulam os dois providers Google e usam dados fictícios; não provisionam recursos no GCP. A suíte específica de bucket foi removida com a adoção exclusiva do estado local. As contagens históricas anteriores estão no registro de evidências.

### Categorias e resultados esperados

Esta tabela resume as simulações Terraform, não os testes Python. Valores abaixo pertencem às entradas fictícias das suítes e podem ser diferentes dos parâmetros de uma implantação. Nos testes negativos, passar significa rejeitar a entrada no ponto esperado, e não aceitar a configuração inválida.

| Categoria | O que verificam | Resultado esperado para aprovação |
| --- | --- | --- |
| Projeto | Criação com billing, labels e política de exclusão; modo existente sem assumir o projeto | Modo criação: 1 projeto, billing informado, labels prod/terraform, política DELETE e rede padrão desativada. Modo existente: 0 projetos e 0 APIs básicas assumidos. |
| Arquitetura | LB externo, duas réplicas em duas zonas e interfaces privadas | LB EXTERNAL_MANAGED; capacidade inicial 2; distribuição em 2 zonas; nenhum access_config de IP público nas VMs. |
| Rede e segurança | Endereço do LB, alocação de IP do NAT, origens do firewall e OS Login | LB com endereço EXTERNAL/IPV4; NAT com MANUAL_ONLY; regra HTTP com origens 35.191.0.0/16 e 130.211.0.0/22; regra IAP com origem 35.235.240.0/20; negação de entrada com prioridade numérica maior que a permissão IAP; enable-oslogin TRUE. Isso não comprova conectividade real do NAT nem autorização efetiva de acesso. |
| Configuração | Repasse de nomes, região, CIDR, tamanho das VMs e labels | No cenário personalizado: rede example-network, sub-rede example-subnet, CIDR 10.90.20.0/24, região us-east1, zonas us-east1-b/c, VMs e2-small com disco de 20 GB e LB example-edge com utilização 0,7. |
| HTTP/HTTPS | Frontends habilitados e rejeição de HTTPS sem certificado | HTTPS exclusivo: 0 proxies/regras HTTP, 1 proxy/regra HTTPS na porta 443, certificado informado e backend HTTP. Com ambos habilitados: os dois frontends existem. HTTPS sem certificado deve ser rejeitado. |
| Scaling e snapshots | Capacidade de duas/três réplicas, política no disco, horário e retenção | Capacidade aceita 2 ou 3; política vinculada pelo template ao disco; padrão diário às 05:00 UTC, retenção 7 dias, local us e retenção aplicada após exclusão da origem. Não comprova criação ou restauração de snapshots. |
| Entradas inválidas | Incompatibilidade entre região/zonas, zonas repetidas, CIDR público, billing ausente e outras combinações inválidas | Cada caso dispara a validação ou precondição indicada em expect_failures; nenhuma entrada inválida é aceita silenciosamente pelo teste. |

Resultado esperado da execução completa: **30 passed, 0 failed**, sem testes ignorados. As suítes e seus arquivos estão relacionados abaixo.

| Suíte | Verificações previstas |
| --- | --- |
| [Labels](../infra/vm-web-platform/tests/labels.tftest.hcl) | Mapas independentes, iguais ou diferentes, mapas omitidos/vazios e rejeição de labels inválidas/reservadas |
| [Projeto](../infra/vm-web-platform/tests/project.tftest.hcl) | Projeto descartável, faturamento, labels e APIs; não assumir projeto existente; rejeição de parâmetros inválidos de faturamento e hierarquia |
| [Topologia](../infra/vm-web-platform/tests/topology.tftest.hcl) | LB externo, réplicas privadas em duas zonas, capacidade de duas/três VMs, rejeição de ambiente/imagem inválidos e HTTP sem aceite |
| [Rede e backup](../infra/vm-web-platform/tests/network-backup.tftest.hcl) | IPs reservados, origens do firewall, vínculo/retenção/local/horário de snapshots, dispositivo de vídeo e utilização |
| [Configuração](../infra/vm-web-platform/tests/configuration.tftest.hcl) | Nomes, localização e dimensionamento personalizados; escolha de HTTP/HTTPS; validação de entradas |

<a id="what-still-needs-a-real-deployment"></a>

## O que ainda exige uma implantação real

As simulações não comprovam permissões efetivas, cotas, propagação das APIs, disponibilidade da imagem, validade do certificado, saúde dos backends, distribuição real de tráfego, ingestão pelo Ops Agent, restauração de snapshots ou exclusão bem-sucedida do projeto. Siga o [guia operacional](../infra/README.md) para validação e limpeza acompanhadas pelo responsável.

Consulte o [registro de evidências](../docs/single-project-validation.md) para distinguir verificações locais concluídas, relatos históricos do responsável sobre dev e testes pendentes desta arquitetura consolidada. As suítes arquivadas de seed/bootstrap não são pré-requisitos.
