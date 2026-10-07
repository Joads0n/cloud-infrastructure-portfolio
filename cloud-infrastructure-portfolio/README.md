# Cloud Infrastructure Portfolio Catalog

Current Landing Zone scope: [single disposable production project (or explicit existing-project test mode)](../gcp-enterprise-landing-zone/docs/single-project-architecture.md), external LB, two private replicas with manual scaling, reserved IPs, firewall, and snapshots. Seed remains preserved; legacy bootstrap is excluded; the new production configuration requires a fresh owner-reviewed plan. All plans/applies are owner-operated. Earlier multi-project execution records below are historical.

This folder contains the shared roadmap, standards, and templates for the infrastructure portfolio. All cases are folders in this same repository; they are not separate Git repositories.

## Cases

| Case | Scope | Evidence status |
| --- | --- | --- |
| [GCP Enterprise Foundation](../gcp-enterprise-foundation/README.md) | Organization hierarchy, administrative IAM, organizational guardrails | Planned; live organizational validation blocked by unavailable organization |
| [GCP Enterprise Landing Zone](../gcp-enterprise-landing-zone/README.md) | Single production project, external LB, private Nginx replicas, telemetry and snapshots | Production configuration ready for review; prior dev tests owner-confirmed |
| [Terraform Enterprise Infrastructure](../terraform-enterprise-infrastructure/README.md) | Future distinct IaC engineering case | Planned; scope to be defined |
| [GCP Secure Network Architecture](../gcp-secure-network-architecture/README.md) | Addressing, routing, DNS, segmentation, network controls | Planned |
| [Cloud Security Architecture](../cloud-security-architecture/README.md) | Workload identity, data protection, hardening, detection | Planned |
| [Cloud Governance Framework](../cloud-governance-framework/README.md) | Standards, policy-as-code checks, exceptions, evidence | Planned |
| [Cloud FinOps Lab](../cloud-finops-lab/README.md) | Cost-management experiments | Planned |
| [Hybrid Cloud Networking](../hybrid-cloud-networking/README.md) | Cross-boundary connectivity, VPN/BGP, simulated peer | Planned |
| [Disaster Recovery](../disaster-recovery/README.md) | Dedicated restore drills, integrity, RTO/RPO measurement | Planned |
| [Workload Migration Case](../workload-migration-case/README.md) | Migration planning, cutover, rollback | Planned |

## Common resources

- [Portfolio standards](docs/portfolio-standards.md)
- [Case README template](docs/templates/case-readme.md) and [ADR template](docs/templates/adr.md)
- [Folder ownership and operational handoff](docs/repository-layout.md)
- [Case boundaries and single resource ownership](docs/decisions/0002-case-boundaries-and-resource-ownership.md)

Keep case-specific documentation and code with its case. Add a new case only for a distinct problem and deliverable. All cases share the existing BRL 300 cumulative portfolio budget.
