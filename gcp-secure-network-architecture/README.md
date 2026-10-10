# GCP Secure Network Architecture

Proposta de arquitetura de rede para a empresa fictícia **Vértice Comércio Digital**, com segmentação, conectividade privada, políticas de firewall, **Cloud NGFW Enterprise com IDS/IPS** e diagnóstico baseado em evidências. O objetivo é permitir somente as comunicações necessárias e explicar por que cada fluxo foi permitido ou bloqueado.

## Empresa e cenário de negócio

A Vértice Comércio Digital é uma empresa fictícia de comércio eletrônico. Sua aplicação de atendimento consulta um serviço interno para obter informações sobre pedidos e disponibilidade de estoque. A empresa também mantém máquinas para diagnóstico e testes, que precisam de acessos específicos, mas não devem consultar diretamente esse serviço.

Este estudo de caso possui cenário, requisitos e ambiente próprios, sem dependência de recursos ou de implantações de outros cases. Empresas, cargas de trabalho e dados são fictícios e não derivam de ambientes de empregadores ou clientes.

## Problema identificado

O cenário inicial pressupõe uma rede que cresceu com permissões excessivas e visibilidade insuficiente:

- **Acessos desnecessários:** máquinas com finalidades diferentes conseguem alcançar serviços que não precisam utilizar.
- **Confiança apenas em IP e porta:** permitir HTTP para um serviço não significa que todo o conteúdo dessa comunicação seja seguro.
- **Diagnóstico difícil:** falhas de DNS, conectividade, firewall e inspeção de segurança são difíceis de distinguir sem evidências correlacionadas.

Essas condições são premissas do cenário fictício, não incidentes reais. A necessidade de negócio é disponibilizar pedidos e estoque à aplicação autorizada, sem conceder o mesmo acesso a qualquer máquina da rede e sem confiar apenas na liberação de uma porta.

## Solução proposta

Separar aplicações e serviços internos em redes e projetos próprios, permitindo comunicação privada apenas nos caminhos necessários. Combinar controles de acesso com inspeção do tráfego autorizado e registros suficientes para investigar falhas.

Uma resposta HTTP simples com dados fictícios representa o serviço de pedidos e estoque. As VMs funcionam como origens e destinos dos testes; o foco é a infraestrutura, não o desenvolvimento de uma plataforma de comércio eletrônico.

## Arquitetura proposta

A topologia prevê duas VPCs conectadas por peering e três VMs pequenas, sem IP público:

- **VPC de aplicações:** VM da aplicação e VM de testes em sub-redes distintas.
- **VPC de serviços internos:** VM que representa o serviço de pedidos e estoque.
- **Cloud NGFW Enterprise:** endpoints associados às redes protegidas, perfis de segurança e políticas para inspecionar os fluxos selecionados.

```text
VPC de aplicações                         VPC de serviços internos
├── Sub-rede da aplicação                  └── Sub-rede de serviços
│   └── VM da aplicação ─── VPC Peering ─────── VM de pedidos e estoque
└── Sub-rede de testes
    └── VM de testes

Políticas de firewall: permitir ou bloquear conforme a matriz de comunicação
Fluxos selecionados: encaminhamento para inspeção pelo Cloud NGFW Enterprise
```

O diagrama representa os caminhos lógicos, não o posicionamento físico dos endpoints de inspeção. O endpoint não é um gateway de peering: as políticas encaminham os fluxos selecionados para inspeção. Sub-redes diferentes não garantem isolamento por si só; as políticas impõem esses limites. O DNS privado tem configuração própria, pois o peering não compartilha automaticamente a resolução de nomes entre redes.

## Escopo de recursos e controles

| Frente | Recursos e controles propostos | Finalidade |
| --- | --- | --- |
| Endereçamento e segmentação | CIDRs sem sobreposição, duas VPCs e sub-redes por responsabilidade | Separar funções e documentar os limites de comunicação |
| Computação | Três VMs sem IP público: aplicação, testes e serviço interno | Exercitar comunicações com origens e destinos identificáveis |
| Conectividade privada | VPC Peering | Comunicação entre aplicação e serviço por IP privado |
| DNS privado | Zona privada e mecanismo explícito de resolução entre redes | Acesso ao serviço por nome interno |
| Políticas de firewall | Network Firewall Policies, prioridades e controles de entrada/saída | Permitir somente os fluxos necessários |
| Inspeção de ameaças | Cloud NGFW Enterprise com IDS/IPS, endpoints e perfis de segurança | Demonstrar detecção e prevenção; requisito obrigatório para conclusão |
| Administração | IAP e OS Login | Administrar VMs sem expor SSH à internet |
| Saída controlada | Cloud NAT e políticas de saída | Permitir saídas necessárias; NAT não substitui firewall nem filtragem de conteúdo |
| Observabilidade | Logs de firewall, registros de ameaças e VPC Flow Logs seletivos | Correlacionar comportamento e decisões dos controles |
| Diagnóstico | Connectivity Tests e inspeção com Network Analyzer | Investigar caminhos, configurações e causas de falhas |
| IaC e testes | Terraform parametrizado, verificações locais e testes reais nas VMs | Implantação reproduzível, resultados verificáveis e limpeza documentada |

## Estrutura organizacional proposta

Uma pasta dedicada delimita o laboratório, com dois projetos que separam as responsabilidades de aplicações e serviços internos:

```text
Organização GCP
└── Pasta: vertice-network-lab
    ├── Projeto: vertice-apps-prd
    │   └── VPC de aplicações
    │       ├── Sub-rede da aplicação → VM da aplicação
    │       └── Sub-rede de testes → VM de testes
    └── Projeto: vertice-services-prd
        └── VPC de serviços internos
            └── Sub-rede de serviços → VM de pedidos e estoque
```

Os nomes são ilustrativos e parametrizáveis. `prd` representa o papel de produção no cenário fictício, não um ambiente produtivo real. A VM de testes é uma origem controlada de validação, não uma carga de negócio de produção.

| Elemento | Responsabilidade |
| --- | --- |
| Organização GCP | Requisito administrativo para a pasta; não é criada nem gerenciada pelo case |
| Pasta do laboratório | Agrupar exclusivamente os projetos do case e delimitar o escopo administrativo |
| Projeto de aplicações | Hospedar as origens de comunicação e os controles da VPC de aplicações |
| Projeto de serviços internos | Hospedar o serviço protegido e os controles de sua VPC |

As Network Firewall Policies são associadas às respectivas VPCs. A separação por projetos define limites administrativos, mas não substitui as regras que controlam o tráfego. Os recursos e o estado Terraform pertencem exclusivamente a este laboratório.

## Critérios de validação

A aceitação da solução depende da comparação entre comportamento esperado e observado. A matriz de comunicação especifica origem, destino, protocolo, porta, permissão ou bloqueio e necessidade de inspeção. Os itens abaixo são critérios de aceitação, não declarações de testes aprovados.

| Exercício | Resultado esperado | Evidência necessária |
| --- | --- | --- |
| Aplicação resolve o nome privado e consulta o serviço | Resolução DNS e resposta HTTP legítima bem-sucedidas | Saídas dos testes de DNS e HTTP |
| VM de testes tenta acessar diretamente o serviço | Bloqueio pela política de firewall | Falha observada, regra responsável e registro correspondente |
| Origem autorizada gera tráfego de teste inofensivo reconhecido pelo IDS/IPS | Detecção registrada e bloqueio confirmado na etapa de prevenção | Resultado do cliente, perfil aplicado e registro de ameaça correlacionados |
| Regra necessária é alterada de forma controlada | Falha diagnosticada e comunicação restaurada após correção | Análise de conectividade e comparação antes/depois |
| VM tenta saída não autorizada | Comunicação bloqueada | Teste negativo e evidência da política responsável |
| Ambiente é desmontado | Recursos do laboratório removidos e resíduos conferidos | Registro de limpeza, incluindo recursos de inspeção e artefatos retidos |

O teste de IDS/IPS deve partir de um caminho permitido pelas regras de acesso; caso contrário, comprovaria apenas um bloqueio de rede. O procedimento deve ser seguro e reproduzível, sem malware real. Provisionar o endpoint, sozinho, não atende ao critério de conclusão.

Análises de configuração não substituem requisições reais nem comprovam sozinhas o funcionamento do IDS/IPS. A avaliação com Network Analyzer não pressupõe que haverá recomendações ou descobertas durante uma sessão curta.

As evidências devem correlacionar origem, destino, horário e controle responsável, sem publicar credenciais ou identificadores privados. O alcance da validação é o conjunto de fluxos e testes documentados, não uma garantia de proteção contra todas as ameaças.
