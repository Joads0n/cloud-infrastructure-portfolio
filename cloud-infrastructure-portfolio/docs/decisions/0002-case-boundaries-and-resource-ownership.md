# 0002: Separate infrastructure disciplines with single resource ownership

Scope update: [Landing Zone ADR 0007](../../../gcp-enterprise-landing-zone/docs/decisions/0007-self-contained-landing-zone-case.md) supersedes the foundation/workload folder split below. Other case boundaries and single resource ownership remain in force.

Status: Accepted by the owner on 2026-10-03. Scope: catalog and design boundaries only; no resource or state migration is authorized.

## Context

The owner wants organization-wide foundation, network architecture, and governance to be distinct portfolio cases, alongside project-level Landing Zone, Terraform engineering, security, FinOps, hybrid networking, disaster recovery, and migration. All remain folders in the existing repository under [ADR 0001](0001-single-repository-catalog.md).

Only the project-level seed has been applied. The current lab has no GCP organization. Several disciplines discuss the same controls, so separating their documentation must not produce duplicated Terraform ownership or unsupported claims of cloud enforcement.

## Decision

Add five planned case READMEs: `gcp-enterprise-foundation`, `gcp-secure-network-architecture`, `cloud-governance-framework`, `hybrid-cloud-networking`, and `disaster-recovery`. Do not add empty implementation trees, new Terraform roots, backends, or resources merely to fill out the catalog.

| Case | Responsibility | Boundary |
| --- | --- | --- |
| Enterprise Foundation | Organization hierarchy, administrative IAM, organizational guardrails, shared-service placement | Future organizational resources only; no automatic adoption of current projects, audit resources, or seed |
| Landing Zone | Existing project-level APIs, bootstrap identity, environment identities, state buckets, audit routing | Existing seed/bootstrap remain here, with their current resource addresses and states |
| Terraform Infrastructure | Module design, environment lifecycle, tests, attended execution/cleanup | Owns the existing Nginx networks, firewall rules, NAT, LBs, and compute; not displaced by the new network case |
| Network Architecture | Addressing, segmentation, routing, DNS, ingress/egress, network firewall controls | Own dedicated future network fixtures; consuming existing workloads does not transfer their state ownership |
| Security Architecture | Workload identity, secrets/data protection, hardening, detection, security validation | Supplies threats and control requirements to Networking; does not independently manage its firewall rules or foundation IAM |
| Governance Framework | Standards, responsibilities, policy-as-code checks, exceptions, evidence mapping | Defines policy intent and checks; the responsible implementation case owns the cloud enforcement resource |
| FinOps Lab | Cost allocation, rightsizing, waste-reduction experiments | One cumulative portfolio ledger; cost controls remain transversal, not exclusive to this case |
| Hybrid Networking | VPN/routing sessions, cross-boundary connectivity, simulated peer and failure tests | Agree attachment and route ownership with Networking; label simulated on-premises accurately |
| Disaster Recovery | Dedicated backup/restore fixtures, incident recovery, measured RTO/RPO | Never use foundation state or another case's live workload as an implicit destructive fixture |
| Workload Migration | Planned source/target transfer, cutover, rollback | Distinct from incident recovery; use explicit fixture and state ownership |

Governance defines a rule, its exception process, and required evidence. Foundation or another implementation case enforces it at the appropriate scope. Security tests security outcomes; Networking tests traffic behavior. Different cases may reference the same evidence but must identify its origin and limitations.

Each managed resource has one owning Terraform root and one authoritative state. Sharing modules, outputs, or validation evidence does not permit duplicate ownership. A future transfer requires a separate ADR, protected state backups, a reviewed migration procedure, and post-transfer validation; do not recreate resources or silently import them into another root. No such transfer occurs here.

Enterprise Foundation begins with scope/design work; implementation and local tests follow requirements. Live organization-wide validation remains pending until a suitable organization and reviewed access are available. Existing project-level work can proceed independently. A management project is not an organization. Compliance claims are limited to mapped requirements and observed evidence, not certification or blanket compliance.

## Alternatives Considered

- Fold Networking and Governance into Security: simpler navigation, but rejected in favor of distinct engineering questions and evidence.
- Add `terraform-gcp-networking` as another case now: deferred because it would overlap the Terraform and Network Architecture cases without a distinct requirement.
- Move existing network resources into the new network case immediately: rejected for this change; catalog organization does not justify a state migration.
- Create separate Git repositories: superseded by the owner's single-repository decision.

## Consequences

Catalog, roadmap, profile source, and case READMEs distinguish planned scope from implemented or applied work. New cases begin with documentation, not claimed validation results. Existing Terraform, private inputs, state, cloud identities, and operational paths remain unchanged.

Complete the existing Landing Zone/bootstrap prerequisites and bounded workload trial before expanding live experiments. Networking/Security and local Governance design can then deepen the existing work, followed by scoped DR and Hybrid trials. Organization-wide deployment has its own prerequisite gate; it is not required to finish the current project-level lab.

## Trade-offs

More cases improve discoverability but increase documentation and maintenance work. Clear boundaries and shared references are preferred over duplicated code or repeated screenshots. New cases share the same cumulative BRL 300 ceiling and one-hour disposable-test limit, including provisioning and cleanup; retained artifacts need explicit lifecycle decisions. Adding a README neither allocates new budget nor authorizes deployment, destructive tests, or publication.
