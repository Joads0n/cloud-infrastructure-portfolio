# Engenharia de Infraestrutura Cloud | GCP e AWS

Este repositório é um catálogo de estudos de caso de infraestrutura em nuvem, com foco em fundações cloud, Terraform, redes, segurança, governança, FinOps, recuperação e migração de cargas de trabalho. Cada case possui empresa fictícia, cenário, requisitos, arquitetura, implementação e critérios de validação próprios.

## Catálogo de cases

| Área | Foco | Situação |
| --- | --- | --- |
| [Catálogo de infraestrutura](cloud-infrastructure-portfolio/README.md) | Roadmap, padrões comuns e índice dos cases | Disponível |
| [GCP Enterprise Foundation](gcp-enterprise-foundation/README.md) | Hierarquia organizacional, limites administrativos e guardrails | Planejado |
| [GCP Enterprise Landing Zone](gcp-enterprise-landing-zone/README.md) | Projeto de produção, LB externo, réplicas Nginx privadas, telemetria e snapshots | Configuração pronta para revisão; testes anteriores de desenvolvimento foram confirmados pelo operador |
| [Terraform Enterprise Infrastructure](terraform-enterprise-infrastructure/README.md) | Engenharia de IaC e desenho de módulos | Planejado |
| [GCP Secure Network Architecture](gcp-secure-network-architecture/README.md) | Endereçamento, segmentação, DNS, políticas de firewall, NGFW e diagnóstico | Escopo e arquitetura propostos |
| [Cloud Security Architecture](cloud-security-architecture/README.md) | Identidade de workloads, proteção de dados, hardening e detecção | Planejado |
| [Cloud Governance Framework](cloud-governance-framework/README.md) | Padrões, verificações de políticas, exceções e evidências | Planejado |
| [Cloud FinOps Lab](cloud-finops-lab/README.md) | Alocação, orçamento, previsão e rightsizing | Planejado |
| [Hybrid Cloud Networking](hybrid-cloud-networking/README.md) | VPN, troca de rotas, conectividade híbrida e diagnóstico de falhas | Planejado |
| [Disaster Recovery](disaster-recovery/README.md) | Backup, restauração, integridade e objetivos de recuperação | Planejado |
| [Workload Migration Case](workload-migration-case/README.md) | Avaliação, cutover, rollback e recuperação | Planejado |

## Como o repositório está organizado

Este é um único repositório Git, com uma pasta independente para cada área. O remoto permanece `Joads0n/cloud-infrastructure-portfolio`; a pasta local é `cloud-portfolio-catalog`. O repositório do README de perfil (`Joads0n/Joads0n`) é separado deste catálogo.

```text
README.md                             # Apresentação e links
cloud-infrastructure-portfolio/       # Catálogo, roadmap e padrões comuns
gcp-enterprise-foundation/            # Fundação organizacional do GCP
gcp-enterprise-landing-zone/          # Cenário, infraestrutura e testes da Landing Zone
terraform-enterprise-infrastructure/ # Engenharia de Terraform
gcp-secure-network-architecture/     # Arquitetura de redes seguras
cloud-security-architecture/         # Segurança de workloads e dados
cloud-governance-framework/          # Governança, exceções e evidências
cloud-finops-lab/                    # FinOps e otimização de custos
hybrid-cloud-networking/             # Conectividade híbrida
disaster-recovery/                   # Exercícios de recuperação
workload-migration-case/             # Migração de cargas de trabalho
```

Os cases são completamente isolados entre si: não compartilham empresa fictícia, cenário, recursos, estado Terraform ou dependência de implantação. Referências entre eles servem apenas para delimitar temas e evitar sobreposição de responsabilidades.

## Evidências e segurança

Testes locais e simulações Terraform são distintos de validações executadas na nuvem. O catálogo deve publicar somente cenários, cargas de trabalho, identificadores, custos e requisitos fictícios, independentes de empregadores e clientes.

Consulte os [padrões do portfólio](cloud-infrastructure-portfolio/docs/portfolio-standards.md) e o [layout do repositório](cloud-infrastructure-portfolio/docs/repository-layout.md).
