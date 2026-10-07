# Workload Migration Case

**Status: Planned.** Folder scaffold only; no implementation, deployment, or validation results are claimed.

Intended focus: assessment, migration strategy, cutover, rollback, and recovery objectives. Define a distinct fictional scenario and acceptance criteria before implementation.

This case covers a planned source/target transfer. [Disaster Recovery](../disaster-recovery/README.md) separately covers incident recovery, backup restoration, and measured data loss. Share methods where useful, but keep fixture and state ownership explicit under the [case boundary decision](../cloud-infrastructure-portfolio/docs/decisions/0002-case-boundaries-and-resource-ownership.md).

## Structure

- `docs/`: requirements, architecture decisions, and evidence when available.
- `infra/`: Terraform only when justified by the case requirements.
- `scripts/`: operational or experiment scripts when needed.

## Next milestone

Define the scenario, scope, constraints, and validation plan using the [common standards](../cloud-infrastructure-portfolio/docs/portfolio-standards.md). Document expected cloud cost and cleanup before provisioning. All cases share the BRL 300 cumulative portfolio ceiling.
