# 0005: Retained foundation and bounded disposable workload sessions

Status: Local implementation and state/audit retention accepted by the owner on 2026-10-03; deployment remains unauthorized.

Date: 2026-10-03

## Context

All three projects and their active billing links are owner-confirmed. The owner set a BRL 300 cumulative budget for bootstrap, all resources, all scenarios, retries, and residual charges, with test-only sessions of at most one hour. Workload code requires pre-existing identities, backends, and audit routing. State is needed to reconcile failed applies and must not be deleted by a workload timer.

## Decision

Use `infra/bootstrap` for separate provisioner/runtime identities, additive scoped IAM, three state buckets, and central audit routing. [ADR 0006](0006-human-seed-and-impersonated-bootstrap.md) refines the initial execution boundary: `infra/seed` now owns APIs and the bootstrap identity/grants, using human credentials; bootstrap explicitly impersonates that identity. Consume existing projects without managing their lifecycle or billing links. Use existing predefined compute roles within isolated lab projects, documenting their breadth rather than claiming a verified custom least-privilege set. Require impersonation explicitly in workload providers and backends.

Retain state/audit foundation resources between tests, as accepted by the owner on 2026-10-03, with a review/retirement horizon within 30 days of the first foundation apply (the earlier seed step under ADR 0006), seven-day noncurrent state versions, soft delete disabled, and a 30-day audit bucket. Record the apply and review dates privately; an extension requires a new owner decision and cost review. Set `accept_retained_foundation=true` explicitly for this lab; retain the reusable variable's default of `false`. This exception does not extend the one-hour workload session or authorize deployment. All costs remain inside BRL 300. Never delete active state to meet a timer.

Implement a Linux attended session controller for one workload environment per session. Offline input/budget checks are the default. Execution requires explicit approval, an isolated initialized GCS backend, a reviewed creation-only saved plan, an empty workload state and independent inventory, and a reservation in a cumulative private ledger. At most 15 minutes are allocated to apply. Normal completion/interruption triggers cleanup; a detached local watchdog attempts cleanup at minute 40. Destruction and inventory checks share the original 60-minute deadline. The optional scaling test must fit inside it. Multiple sessions consume the same cumulative budget.

The controller refuses bootstrap, project/IAM/storage changes in workload plans, imports, existing-state adoption, cross-project changes, and overlapping unreconciled sessions. It destroys only the selected workload state. Independent GCP list queries check expected lab-prefixed resource types; they never delete resources based on a prefix. Failed deletion, failed queries, or residual resources are failures, not proof of cleanup. Reserved money remains unreported until billing reconciliation, including after successful teardown.

## Alternatives Considered

- Rebuild/delete remote state and logging every hour: rejected as the default because it complicates recovery, migration, and evidence retention; remains a user-selectable redesign if retained foundation is unacceptable.
- Grant Owner to workload automation: rejected; separate compute/network roles, runtime act-as, own-bucket access, and explicit impersonation provide more useful boundaries.
- Custom compute role immediately: deferred pending runtime permission evidence; a guessed custom role could break cleanup. Predefined roles are restricted to disposable project scope and their risks are recorded.
- Cloud-hosted watchdog: provides better independence from a workstation but adds another executor, credentials, deployment, and operational cost. Not silently introduced; required for an unattended deployment or stronger host-failure guarantee.
- Budget alerts as a hard stop: rejected; delayed billing and notifications are not a reliable runtime controller.

## Consequences

Local tests can validate configuration and control flow without creating resources. They do not establish effective IAM, API availability, propagation, startup time, real deletion time, or charges. The first live session must remain attended, validate credential refresh, and exercise early failure/cleanup before running the full scenario. An Owner-based cloud test cannot prove environment isolation.

Bootstrap needs temporary administrative privileges and an initially protected local state. Migrating its backend is a deliberate operator step. APIs are not disabled on destroy; IAM policies remain additive. Sink writer access is write-only but management-project-scoped, not exclusive to one destination bucket.

## Trade-offs

A detached local watchdog survives controller exit but not workstation shutdown, lost connectivity, expired credentials, or cloud API outages. Terraform operations can finish late or leave partially created resources; the one-hour target cannot be guaranteed by this implementation. Deployments remain blocked if the owner needs an absolute technical one-hour cap under those failures. No blanket budget or cleanup guarantee is claimed.

Versioned state is not immutable against its own provisioner. `prevent_destroy` is a code guard, not a security boundary. Retained-state/log costs need recurring ledger reconciliation until retirement. Cost figures are scenario estimates, not billing quotes or authorization to spend the BRL 300 ceiling.
