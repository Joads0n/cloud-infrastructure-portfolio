# 0002: Separate environment projects and shared management services

Status: Proposed architecture; the multi-project planning direction is authorized. Deployment is not authorized.

Date: 2026-10-02

Replaces the unimplemented proposal in [ADR 0001](0001-project-level-foundation-lab.md).

## Context

The approved fictional case needs evidence of environment access boundaries, audit review, reproducible changes, recovery, and cost ownership. The single-project proposal left administrative isolation incomplete. The owner authorized proceeding with the architecture of the two additional environment projects previously discussed.

Interpret the scope as development and simulated production projects plus the existing project for management: three projects total. Reuse depends on confirming the existing project is a suitable personal lab. No organization is available; creation quota, billing permissions, and administrative access have not been inspected.

## Decision

- Give dev and prod distinct project IAM boundaries, custom networks, scoped Terraform identities, and state buckets.
- Use the management project for three separately permissioned state buckets and one custom Cloud Logging audit bucket. Do not add a management VPC without a traffic requirement.
- Route selected audit events from each environment directly into the central log bucket using project sinks and reviewed writer permissions. Bootstrap owns sinks and destination permissions; ordinary network provisioners do not administer them.
- Use separate Terraform roots for bootstrap, dev, and prod, with explicit resource ownership and no authoritative replacement of existing project IAM policies.
- Include short-lived private VM probes, IAP/OS Login administration, positive and negative access tests, and a controlled state-recovery exercise in the future costed demonstration.
- Keep organization/folder controls and Shared VPC as reference-design topics, clearly outside demonstrated lab coverage.

The detailed [architecture](../proposals/gcp-landing-zone-architecture.md) and [validation plan](../proposals/gcp-landing-zone-validation.md) specify intended behavior and evidence. They do not assert any successful cloud test.

## Alternatives Considered

- **Single project, two VPCs:** smaller setup, but project-wide administrative grants reach both environments and do not satisfy the intended access-boundary demonstration.
- **Two projects total, with state and central logs in dev or prod:** fewer project responsibilities, but shared management services would sit inside a workload environment. Reject that coupling for this case; two additional projects preserve the existing project's management role.
- **One management state bucket with prefixes:** separates Terraform state objects, but bucket-wide grants would expose all environments. Separate buckets make the intended backend access policy directly testable.
- **One shared Terraform state and provisioner:** simpler orchestration, but increases cross-environment privileges and the scope of an incorrect apply.
- **Independent state/logging management projects or an organization-level foundation:** supports further separation, but adds scope beyond the currently available environment and the case's first control objectives. Revisit when an independent security team or organization access becomes available.

## Consequences

The design creates testable project and state-access boundaries and explicit cross-project audit dependencies. Bootstrap needs broader, carefully reviewed authority; ordinary provisioners remain narrower. Backend storage, audit copies, and temporary endpoints require cost estimates and cleanup procedures before deployment.

Centralizing state and logs shares a management failure domain. The sole owner can still administer all projects, so human independence and administrator-proof logs are not demonstrated. A source administrator can interrupt future log routing; source platform audit storage remains important.

## Trade-offs

The extra projects and backend buckets add bootstrap work but serve concrete access-control and evidence requirements. Separate project boundaries still depend on correct IAM and impersonation configuration; they do not guarantee isolation by themselves. Network tests need healthy endpoints and positive controls before interpreting denied connections.

Validate these choices through SEC-01, NET-01, OBS-01, IAC-01, and REL-01 tests. Revisit management consolidation if independent security administration is required, and revisit network connectivity only when an approved workload flow needs it. Implementation remains subject to region, role, cost, and environment preflight checks.
