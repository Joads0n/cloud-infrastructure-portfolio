# 0001: Single-repository catalog with case folders

Scope update: [Landing Zone ADR 0007](../../../gcp-enterprise-landing-zone/docs/decisions/0007-self-contained-landing-zone-case.md) supersedes the foundation/workload folder split below. Other case boundaries and single resource ownership remain in force.

Status: Accepted by the owner on 2026-10-03.

## Context

The portfolio covers multiple infrastructure disciplines. Planning and the initial GCP lab were mixed at the root. The owner requested one catalog with separate folders, each holding its documentation and applicable Terraform/scripts.

## Decision

Keep one Git repository and its existing remote name. Put common planning and standards under `cloud-infrastructure-portfolio/`. Create peer case folders for GCP foundation, Terraform infrastructure, security, FinOps, and migration. The root README presents the portfolio; the existing GitHub profile uses a separately prepared README source.

Keep seed/bootstrap and their tests in the GCP case. Put workload modules/environments and the session controller in the Terraform case. Terraform suites stay in each configuration's local `tests/` directory; case-level `tests/` directories provide test indexes and, for the workload case, Python tests. Terraform rejects external `-test-directory` paths. Preserve resource/state ownership, shared private recovery files, and the cumulative cost ledger. Add implementation to planned cases only when requirements justify it.

## Alternatives Considered

- Independent repositories per case: rejected by the owner; the intended deliverable is one catalog organized by folders.
- Keep all code and documents at the root: simpler paths, but mixes common planning with case-specific evidence.
- Duplicate foundation code in each case: rejected because it obscures state ownership and maintenance responsibility.

## Consequences

Cases share Git history, repository protections, issue templates, and safety rules. Relative Markdown links work across cases. Documentation must identify the working directory for commands and distinguish local validation from cloud results.

## Trade-offs

A single repository simplifies navigation and common standards, but does not provide independent repository permissions or release boundaries. The Terraform workload case depends on the GCP foundation; folder separation does not create IAM or state isolation by itself.
