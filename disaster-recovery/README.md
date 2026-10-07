# Disaster Recovery

**Status: Planned.** Scope definition only; no restore drill, measured recovery objective, or disaster-recovery capability is claimed.

## Objective and scope

Design and rehearse recovery of a fictional Cedar Route Logistics service with synthetic persistent data. Define recovery time (RTO) and acceptable data loss (RPO), then measure observed recovery and data integrity against those objectives.

Begin by evaluating backup-and-restore with recovery capacity created on demand. Do not assume that load-balancer failover or rebuilding a static page demonstrates data recovery, or that a small lab simulates a full regional outage.

## Dependencies and ownership

- [Landing Zone](../gcp-enterprise-landing-zone/README.md) provides reusable infrastructure patterns, not permission to destroy its resources.
- [Landing Zone](../gcp-enterprise-landing-zone/README.md) remains responsible for foundation state and identity recovery. Do not use the live seed state or bootstrap buckets as destructive test fixtures.
- This case will own dedicated source/recovery fixtures, backup lifecycle, restore automation, and its runbook. Specify the state boundary before implementation.
- [Workload Migration](../workload-migration-case/README.md) covers a planned transfer and cutover; this case covers recovery following a controlled incident. Share patterns without sharing ambiguous resource ownership.

## Expected evidence — not yet produced

A business-impact scenario; justified RTO/RPO targets; a backup/restore runbook; timestamped observed recovery; synthetic-data checksums and loss assessment; credential/dependency failure analysis; residual-cost accounting; and cleanup evidence. Mark unmet objectives as failures rather than redefining them after the drill.

## Next milestone and operating limits

Choose a minimal stateful fixture and objectives compatible with the lab constraints. Keep fault injection restricted to disposable fixtures; obtain explicit approval for destructive experiments.

Include backup storage, restore operations, retained copies, and recovery capacity in the shared BRL 300 ceiling. Disposable tests include provisioning and cleanup within the approved one-hour window; any retained backup needs an explicit retention decision. See the [ownership decision](../cloud-infrastructure-portfolio/docs/decisions/0002-case-boundaries-and-resource-ownership.md).
