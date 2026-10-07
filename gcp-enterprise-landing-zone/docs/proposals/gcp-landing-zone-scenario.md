# Approved Scenario: GCP Enterprise Landing Zone

Historical multi-project proposal. Superseded by the [single-project architecture](../single-project-architecture.md) and its runbook. Old resource counts, deployment commands, estimates, and validation status below are not the current baseline.

Status: scenario and documentation-first scope approved by the owner on 2026-10-01. On 2026-10-02 the owner confirmed a GCP project with billing and no organization, then authorized planning two additional environment projects. The current design has three projects total; deployment is not authorized.

Update 2026-10-03: the owner confirmed that both dev and prod projects have already been created. Bootstrap will consume all three existing projects rather than create them. Billing attachment, permissions, APIs, and resource inventory still require verification; owner confirmation is not a cloud validation result.

## Fictional business problem

**Cedar Route Logistics** is an invented company used solely for this portfolio. It has 80 employees, three operating sites in Brazil, two workload teams, and a two-person infrastructure team. These figures and all requirements below are synthetic assumptions, unrelated to any employer or customer.

The company plans to move an internal shipment-tracking workload and a daily operational reporting workload to GCP. Before migration, it needs a cloud foundation that makes environment ownership, access, network boundaries, audit evidence, and cost allocation explicit. The case delivers the infrastructure foundation; application development and the migration itself are separate work.

## Approved scope

Design a foundation for development and production environments. Describe platform administration, workload operations, security review, and financial ownership as separate responsibilities, even when the small fictional team requires one person to hold multiple responsibilities.

The target deliverables are a requirements matrix, architecture overview, material ADRs, and a validation plan. Terraform follows only after the scenario and architecture are reviewed. Evidence must distinguish design review, local configuration checks, and checks that require an actual cloud environment.

## Requirements baseline

The [requirements and validation brief](gcp-landing-zone-requirements.md) expands the following requirements into acceptance criteria. Approval of this scenario does not establish that any control has been implemented or tested.

| ID | Requirement | Acceptance evidence |
| --- | --- | --- |
| GOV-01 | Every environment and workload has an owner, purpose, and cost-allocation convention | Resource and ownership inventory with fictional examples |
| SEC-01 | Access is mapped to responsibilities, with elevated access and emergency use explicitly addressed | IAM matrix and review of representative allowed and denied actions |
| NET-01 | Development and production have explicit network boundaries and documented permitted traffic | Address plan and traffic matrix with isolation checks |
| SEC-02 | Workloads have no direct public administrative access by default | Administrative access design and applicable configuration checks |
| OBS-01 | Administrative activity can be reviewed by the security responsibility | Logging design, access model, and a planned audit-event validation |
| FIN-01 | Every component considered for deployment has a cost assumption, owner, and cleanup procedure | Dated estimate with pricing sources before deployment; teardown checklist |
| IAC-01 | Infrastructure changes are reproducible and reviewed | Versioned configuration, environment/state isolation design, and proportionate validation evidence |
| REL-01 | The foundation has documented configuration recovery and operational ownership | Recovery procedure, dependencies, and a planned recovery exercise |

These are requirements, not demonstrated controls. The requirements brief records proposed synthetic operational targets separately from the approved scenario. Application availability, RTO/RPO, and traffic volumes remain outside this foundation's guarantees. No compliance certification or production readiness is claimed.

## Constraints and alternatives to evaluate

- Begin with documentation and local validation. This phase provisions nothing and incurs no cloud resource charges.
- Available environment: one GCP project with billing, without an organization. Propose reusing it for management and adding dev/prod projects. Suitability, creation quota, and effective permissions remain to be verified before deployment.
- Distinguish the enterprise reference from the multi-project lab: no organization, folders, or inherited organization-level guardrails are claimed as deployed.
- Use one independent network per environment with no interconnection; state and logging management services require no management VPC. Revisit connectivity only for an approved workload flow.
- Use the owner-selected `us-central1` region for the laboratory, as recorded in ADR 0003. On 2026-10-03 the owner set a BRL 300 cumulative ceiling for the entire portfolio and test-only sessions of at most one hour, including provisioning and cleanup. Finalize costs and cleanup controls within those constraints before requesting deployment authorization.
- Use invented private address ranges and placeholder identifiers when designing the network. Do not reuse professional environment artifacts.

The current lab scope is recorded in [ADR 0002](../decisions/0002-multi-project-foundation-lab.md), with network, logging, IAM, and state boundaries in the [architecture](gcp-landing-zone-architecture.md) and concrete checks in the [validation plan](gcp-landing-zone-validation.md). ADR 0001 preserves the superseded single-project alternative. Reviewed design artifacts, foundation and workload Terraform, and validation/cleanup scripts all live in this case folder. Nginx is a synthetic acceptance fixture, not a software-development deliverable.

## Exclusions from the first case

Application implementation, a live workload migration, an always-on hybrid connection, a second cloud deployment, and multi-region disaster recovery are excluded. Dependencies on those capabilities may be documented for later cases.

## Review and next deliverable

The owner approved the fictional logistics scenario, GCP focus, two environments, and documentation-first scope, then authorized the multi-project architecture work and selected `us-central1`. Next, resolve zone/machine selection, exact IAM mappings, project provisioning method, backend lifecycle, and a priced validation window before implementation or deployment. Scenario approval does not create projects or authorize spending.
