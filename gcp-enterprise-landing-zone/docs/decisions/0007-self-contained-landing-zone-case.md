# 0007: Deliver Landing Zone as a self-contained engineering case

Status: Accepted by the owner on 2026-10-03. File consolidation only; no cloud deployment authorization.

## Context

The fictional Cedar Route Logistics scenario spans project-level foundations and a small Nginx topology used to validate environment isolation and ingress. Splitting its implementation between Landing Zone and Terraform Infrastructure makes one solution appear to be two cases and forces readers to cross folders to understand the outcome. The owner wants to finish Landing Zone before expanding the portfolio.

Only seed has been applied. Bootstrap and workload roots remain unapplied. No workload state or private session directory was found in the former Terraform case during the move. Seed state and private recovery records must remain protected.

## Decision

Keep the scenario, requirements, architecture, ADRs, all Terraform for this scenario, session scripts, tests, and evidence navigation in `gcp-enterprise-landing-zone/`. Preserve existing document names under `docs/proposals/` rather than rename them solely for presentation.

Move the shared workload module, dev/prod roots, scripts, Python tests, infrastructure guide, and foundation-dependency guide from the Terraform case into Landing Zone. Keep Terraform mock suites local to their configuration roots. Retain four independent roots: seed, bootstrap, dev, and prod. No resource addresses, provider identities, backends, module source expressions, or state contents change.

The Landing Zone owns its VPCs, subnets, firewall rules, NAT, internal dev Application LB, global external prod Application LB, one dev VM, and two prod Nginx backends. These are acceptance fixtures, not a software portfolio. Optional bounded scaling/failure experiments still need separate reviewed authorization.

The Terraform Infrastructure case becomes planned, with a distinct problem yet to be defined; it does not retain a duplicate implementation. Other planned cases keep their discipline boundaries and must justify separate scenarios and resource ownership.

This decision supersedes only the foundation/workload folder split in catalog ADRs 0001 and 0002. The single repository, single authoritative state per resource, and organization-wide Foundation distinction remain unchanged.

## Alternatives Considered

- Keep cross-case references: less file movement, but fragments the primary case and overstates the number of distinct implementations.
- Copy the workload code into both cases: rejected because it creates duplicate maintenance and ambiguous resource ownership.
- Merge all Terraform into one root/state: rejected because retained foundations and disposable workloads have different credentials, recovery needs, and lifecycles.
- Add organization-level infrastructure now: rejected; no suitable organization exists and it is outside this project-level scenario.

## Consequences

All scenario commands run from Landing Zone, or use its prefix with `-chdir` from the repository root. Root `.private/` continues to hold shared private inputs, tools, recovery records, and the single cumulative ledger. New session receipts use Landing Zone's ignored `.private/`. Private session paths must be reviewed and workload plans regenerated; historical plans/receipts must not be resumed at former paths. Seed/bootstrap paths remain unchanged.

No apply, destroy, import, state move, backend migration, API enablement, or IAM change is part of this consolidation. Live acceptance remains pending. Keep the BRL 300 cumulative ceiling, one-hour disposable session including cleanup, teardown starting by minute 40, and retained-foundation review by 2026-11-02. A local watchdog is not an absolute deadline guarantee.

## Trade-offs

Landing Zone includes more code, but presents one coherent problem and solution. Module reuse remains local and justified by dev/prod similarities. Deferring the Terraform case reduces breadth of current portfolio claims while avoiding duplicated evidence. Separate roots preserve operational complexity where safety requires it.
