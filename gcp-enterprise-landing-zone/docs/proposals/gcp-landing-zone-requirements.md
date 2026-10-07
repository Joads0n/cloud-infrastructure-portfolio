# GCP Landing Zone Requirements and Validation Brief

Historical multi-project proposal. Superseded by the [single-project architecture](../single-project-architecture.md) and its runbook. Old resource counts, deployment commands, estimates, and validation status below are not the current baseline.

Status: requirements baseline for the [approved Cedar Route Logistics scenario](gcp-landing-zone-scenario.md). The [multi-project architecture](gcp-landing-zone-architecture.md) and [validation plan](gcp-landing-zone-validation.md) define the design. A [local Nginx ingress Terraform slice](../../infra/README.md) now exists; only seed has been applied; bootstrap, workload deployment, and runtime validation remain pending. Operational targets below are explicitly proposed synthetic assumptions.

## Business objective and scope

Prepare a GCP foundation for development and production supporting two future fictional workloads: internal shipment tracking and daily operational reporting. The first case must demonstrate how ownership, access, networking, logging, costs, and recovery requirements inform infrastructure decisions.

This case folder owns the complete scenario: brief, requirements, architecture, ADRs, seed/bootstrap, workload networks, dev/prod Terraform, and validation/cleanup scripts. Separate roots retain separate state and identity boundaries.

On 2026-10-03, active management/dev/prod projects, billing links, and required human seed permissions were API-verified before the separately authorized seed apply (arquivo histórico na recuperação privada; fora da entrega pública). No organization is available. Bootstrap consumes existing projects without managing project creation/deletion or billing and remains unapplied. Broader inventory and effective-policy isolation remain open. SEC-01 has cross-project and state-access tests but is not satisfied by seed execution alone. Organization-level controls and independent human administration remain outside demonstrated coverage. See [ADR 0002](../decisions/0002-multi-project-foundation-lab.md) and bootstrap implementation (arquivo histórico na recuperação privada; fora da entrega pública).

## Responsibilities

| Responsibility | Accountability in the fictional scenario |
| --- | --- |
| Platform administration | Foundation changes, network ownership, infrastructure state, and configuration recovery |
| Workload operations | Workload-specific access requests and service operations within an assigned environment |
| Security review | Access reviews, audit investigation, and review of elevated or emergency access |
| Financial ownership | Cost allocation, forecast review, and approval of the fictional organization's expenses |

The fictional infrastructure team has two people, so responsibilities are not assumed to map to four dedicated staff members. Document overlapping duties and their limitations. The real portfolio owner is a solo maintainer; PR self-review does not demonstrate independent approval or separation of duties.

## Requirements and acceptance criteria

| ID | Acceptance criteria | Design/local evidence | Additional evidence needed after deployment |
| --- | --- | --- | --- |
| GOV-01 | Every planned environment and workload has a named fictional owner, purpose, lifecycle, and cost-allocation convention; label exceptions are explicit | Resource inventory and naming/metadata review | Compare actual resources and supported metadata against the inventory |
| SEC-01 | Each responsibility has an access boundary; ordinary workload operators cannot administer the foundation or an unrelated environment; elevated and emergency access have review and revocation procedures | Access matrix including allowed and denied actions, reviewed against chosen role definitions | Execute representative allowed and denied actions with dedicated lab identities and record outcomes |
| NET-01 | Address ranges do not overlap; development-to-production communication is denied unless individually justified; each permitted flow has source, destination, protocol, purpose, and owner | Address plan, traffic matrix, and review of routing and firewall configuration | Test permitted and forbidden paths using temporary lab endpoints |
| SEC-02 | Workload administration has no direct public ingress by default; any outbound internet dependency is explicit | Administrative access path and review for unintended public exposure | Confirm actual public exposure and test the approved administration path |
| OBS-01 | Administrative activity has a defined collection scope, review responsibility, retention target, and access boundary | Event coverage matrix and logging design, including excluded events and known gaps | Generate a harmless administrative event, locate it, and verify reviewer access and unauthorized-access denial |
| FIN-01 | Prioritize right-sizing and verified Free Tier headroom; allow justified billable services; each component has an owner, usage assumption, estimate date/source, and cleanup procedure | Allowance ledger including other account usage, complete cost model, and cleanup checklist before deployment authorization | Reconcile deployed resources and observed usage with allowances/estimates; confirm cleanup and later billing observations |
| IAC-01 | Environments have explicit state and change boundaries; sensitive inputs, state, and plans stay outside version control; tool/provider versions and authentication are documented | Configuration review and proportionate formatting, validation, linting, and security checks after code exists | Verify a plan targets only the intended environment and that state access and locking match the design |
| REL-01 | Recovery identifies source configuration, state, credentials, external dependencies, responsibility, and a sequenced procedure | Recovery runbook and a tabletop exercise that identifies unresolved dependencies | Rebuild a disposable demonstration environment and measure recovery against the agreed target |

All checks above are planned. A configuration review cannot establish runtime isolation, effective permissions, audit delivery, or recovery performance.

## Proposed operational targets

These values make the case testable; they are invented planning assumptions, not measured results, provider guarantees, or regulatory obligations. Validate cost and feasibility before accepting them in the architecture.

| Target | Proposed assumption | Boundary |
| --- | --- | --- |
| Audit retention | At least 30 days searchable for selected administrative events | Preserve platform-required retention; additional data-access logging requires a separate coverage and cost decision |
| Configuration recovery time | Restore the disposable foundation configuration within 8 hours after recovery starts | Project, billing, identity access, and necessary external dependencies must remain available; excludes workload and data recovery |
| Configuration recovery point | Recover the latest approved configuration and the last successful state write within the available recovery history | Propose 7 days of noncurrent state-version history; validate lifecycle, soft-delete behavior, and reconciliation before apply |
| Change traceability | Every foundation change links to a PR with validation evidence | Independent reviewer approval is not claimed for this solo portfolio |
| Current cloud spending | Only seed API/IAM configuration applied; actual charges not reconciled | BRL 300 cumulative portfolio ceiling; bootstrap/workload estimates and separate approval remain required |

The owner prioritizes economical resources and recurring free allowances, but accepts public IPs, global load balancing, NAT, and other billable resources when justified. The [usage and cost plan](gcp-landing-zone-cost-plan.md) gives the initial private-probe profile a conditional USD 0 incremental estimate, not a zero-cost-only constraint. Do not treat three projects as three independent Compute/Storage allowances or assume an unverified trial credit.

## Open inputs and decision sequence

1. Available environment: existing management project with billing and no organization; on 2026-10-03 the owner also confirmed existing dev/prod projects. No project creation is needed. Before deployment, verify suitability, billing attachment, APIs, permissions, and existing resources in each project. Keep real IDs in private runtime inputs, never repository artifacts; do not request credentials or professional-environment details.
2. Review the three-project design and its explicit enterprise-control gaps. Keep the superseded single-project proposal as decision history rather than the current implementation target.
3. Map the designed resource boundaries, IAM capabilities, logging writers/readers, and backend isolation to exact provider resources and minimum required permissions. ADR 0002 records the material architecture choices.
4. Use the owner-selected `us-central1` region from [ADR 0003](../decisions/0003-us-central1-lab-region.md). Select zone, machine, and service-specific configurations using current official documentation and dated cost estimates; regional selection alone is not a cost estimate.
5. Review architecture and validation scope before Terraform. Decide separately whether any cloud demonstration is authorized and affordable.

The three-project design and owner-reported project existence are established; effective permissions, billing attachment for dev/prod, existing resource conflicts, implementation details, and deployment approval remain open. None of these details should be inferred from project existence alone.

## Evidence record format

For each executed check, record the requirement ID, configuration revision, method, expected result, actual result, date, limitations, and a publication-safe evidence reference. Use **planned**, **passed**, **failed**, or **not executed** as appropriate. Keep real identifiers, authentication material, and raw cloud output out of committed evidence.
