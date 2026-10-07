# Cloud Infrastructure Engineering | GCP & AWS

Current Landing Zone scope: [single disposable production project (or explicit existing-project test mode)](gcp-enterprise-landing-zone/docs/single-project-architecture.md), external LB, two private replicas with manual scaling, reserved IPs, firewall, and snapshots. Seed remains preserved; legacy bootstrap is excluded; the new production configuration requires a fresh owner-reviewed plan. All plans/applies are owner-operated. Earlier multi-project execution records below are historical.

A portfolio catalog covering cloud foundations, Terraform, networking, security, governance, FinOps, recovery, and workload migration. Cases use fictional scenarios to connect requirements, architecture decisions, implementation, and validation evidence.

## Explore the catalog

| Area | Focus | Status |
| --- | --- | --- |
| [Portfolio catalog](cloud-infrastructure-portfolio/README.md) | Roadmap, shared standards, and case index | Available |
| [GCP Enterprise Foundation](gcp-enterprise-foundation/README.md) | Organization hierarchy, administrative boundaries, organizational guardrails | Planned; organization unavailable |
| [GCP Enterprise Landing Zone](gcp-enterprise-landing-zone/README.md) | Single production project, external LB, private Nginx replicas, telemetry and snapshots | Production configuration ready for review; prior dev tests owner-confirmed |
| [Terraform Enterprise Infrastructure](terraform-enterprise-infrastructure/README.md) | Future distinct IaC engineering case | Planned; scope to be defined |
| [GCP Secure Network Architecture](gcp-secure-network-architecture/README.md) | Addressing, segmentation, routing, DNS, traffic controls | Planned |
| [Cloud Security Architecture](cloud-security-architecture/README.md) | Workload identity, secrets/data protection, hardening, detection | Planned |
| [Cloud Governance Framework](cloud-governance-framework/README.md) | Standards, policy checks, exceptions, control evidence | Planned |
| [Cloud FinOps Lab](cloud-finops-lab/README.md) | Allocation, budgets, forecasting, rightsizing | Planned |
| [Hybrid Cloud Networking](hybrid-cloud-networking/README.md) | VPN, route exchange, peer simulation, failure diagnosis | Planned |
| [Disaster Recovery](disaster-recovery/README.md) | Backup/restore, data integrity, measured recovery objectives | Planned |
| [Workload Migration Case](workload-migration-case/README.md) | Assessment, cutover, rollback, recovery | Planned |

## Organization

This is **one Git repository**, with one folder per area. The GitHub remote remains `Joads0n/cloud-infrastructure-portfolio`; the local folder is `cloud-portfolio-catalog`. `Joads0n/` in the conceptual portfolio diagram represents the GitHub profile, not another local repository or nested checkout.

```text
README.md                              # Presentation and links
cloud-infrastructure-portfolio/         # Catalog, roadmap, common standards
gcp-enterprise-foundation/             # Planned organization-wide foundation
gcp-enterprise-landing-zone/           # Complete scenario, foundation, networks, workloads, tests
terraform-enterprise-infrastructure/  # Planned distinct IaC case; scope to be defined
gcp-secure-network-architecture/      # Planned network architecture
cloud-security-architecture/          # Docs, infra, tests
cloud-governance-framework/            # Planned rules, exceptions, evidence
cloud-finops-lab/                      # Docs, infra, scripts
hybrid-cloud-networking/               # Planned hybrid connectivity
disaster-recovery/                    # Planned recovery drills
workload-migration-case/              # Docs, infra, scripts
```

The catalog and ten case folders are peers at the repository root. The existing GitHub profile repository is separate from this catalog; local planning and profile drafts are not part of this delivery.

[Case boundaries and resource ownership](cloud-infrastructure-portfolio/docs/decisions/0002-case-boundaries-and-resource-ownership.md) distinguish organizational Foundation from project-level Landing Zone and keep Networking, Security, and Governance separate. The [Landing Zone consolidation](gcp-enterprise-landing-zone/docs/decisions/0007-self-contained-landing-zone-case.md) brings its workload roots into the same case without merging states or changing resources. Other cases remain planned.

## Evidence and safety

Local mock tests are distinct from cloud validation. Planned cases contain scaffolding only. Public scenarios, workloads, identifiers, costs, and requirements must be fictional and independent of employer or customer artifacts.

See the [portfolio standards](cloud-infrastructure-portfolio/docs/portfolio-standards.md), the case status table above, and the [repository layout](cloud-infrastructure-portfolio/docs/repository-layout.md).
