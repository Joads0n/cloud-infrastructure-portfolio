# Cost-Aware Lab Usage and Cost Plan

Historical multi-project proposal. Superseded by the [single-project architecture](../single-project-architecture.md) and its runbook. Old resource counts, deployment commands, estimates, and validation status below are not the current baseline.

Status: owner-directed cost and duration limits, updated 2026-10-03. The total portfolio spending ceiling is BRL 300, with test-only usage and sessions no longer than one hour. Prioritize right-sized resources and verified free allowances. Account eligibility, remaining allowances, and actual usage have not been inspected. The ceiling is a constraint, not authorization to deploy or spend the entire amount.

This plan refines the [architecture](gcp-landing-zone-architecture.md) and [validation plan](gcp-landing-zone-validation.md). All usage figures below are fictional planning assumptions, not measured consumption. Free Trial credits are not assumed; recurring Free Tier allowances are the priority.

The [whole-lab session estimate](gcp-lab-session-estimate.md) now includes compute, disks, network processing/transfer, bootstrap state operations/storage, and central audit retention. Its illustrative BRL envelope uses explicitly invented planning factors, not a current FX/tax quote. The local controller (arquivo histórico na recuperação privada; fora da entrega pública) and bootstrap (arquivo histórico na recuperação privada; fora da entrega pública) are implemented; retention was owner-approved on 2026-10-03, while cloud verification remains pending.

## Portfolio-wide budget and session boundary

- BRL 300 is cumulative across all portfolio cases, projects, providers, and repeated tests; it does not reset monthly or per environment. Include taxes, currency effects, delayed charges, failed deployments, retained storage/logs, and cleanup costs.
- Interpret the owner's one-hour limit conservatively as a shared session window from the first cloud resource creation operation through verified workload cleanup, including provisioning, boot, health convergence, tests, and deletion. It is not one hour per VM or an extra hour for scaling. Split exercises into separately costed sessions if necessary; never extend a running session silently.
- Prepare code, approvals, and plans before the resource window. The local controller limits apply to 15 minutes and attempts cleanup by minute 40, targeting inventory reconciliation by minute 60. Skip remaining tests if setup runs late. Timers are implemented and mock-tested, not live-verified or a guarantee against cloud API delays.
- Before each session, maintain a private ledger: settled cost, estimated unreported/retained cost, next-session estimate including cleanup/contingency, and remaining BRL balance. Do not proceed if the conservative combined estimate exceeds BRL 300. Do not publish real billing exports or account identifiers.
- Do not keep VMs, LBs, NAT, or reserved test IPs running between sessions. The owner accepted persistent Terraform state and audit retention on 2026-10-03, with review/retirement within 30 days of first foundation (seed) apply and all retained costs inside the same cap. Record those dates privately; extensions require renewed approval and cost review. Do not delete active state or required evidence just to satisfy a timer. Retention acceptance is not deployment authorization.
- Automated workload cleanup on success/failure, a detached local watchdog, and state-independent inventory queries are implemented with unit/mock coverage. They still require an attended live validation and cannot survive host/network/credential loss. Alerts alone are not the controller. Bootstrap is not a disposable-workload cleanup target.

## Active profile: internal dev LB and external prod LB

[ADR 0004](../decisions/0004-environment-application-load-balancers.md) and the [implementation slice](../../infra/README.md) supersede the private-probe topology below. Plan one dev Nginx VM and two prod Nginx VMs within one shared hour (up to 3 baseline VM-hours), one internal dev Application LB, one global external prod Application LB, and one NAT gateway with one reserved address per environment. An optional third prod VM must fit inside that same window; include its incremental VM-hours, disk, NAT usage, and downloads, not an extension of the session.

Published USD rates checked 2026-10-02, recalculated on 2026-10-03 for illustrative one-hour allocations. These are historical reference rates, not a newly verified quote or a BRL conversion:

| Meter | Rate / assumption | One-hour subtotal |
| --- | --- | --- |
| Dev internal LB proxies | At least three managed proxies × USD 0.025/proxy-hour in `us-central1`, even idle | USD 0.075 minimum |
| Prod global forwarding rule | USD 0.025/hour for the initial global-rule tier, assuming no existing applicable rules in this new project | USD 0.025 |
| NAT gateways serving three VMs total | USD 0.0014/VM-hour at this small size | USD 0.0042 |
| Two NAT IPv4 addresses | USD 0.005/address-hour | USD 0.01 |

The **partial time-based subtotal is USD 0.1142 for one hour**, not a complete estimate, proof of affordability, or a spending cap. Internal proxy capacity can scale. Destroy networking after tests; VM shutdown alone does not remove LB/address charges.

The [expanded estimate](gcp-lab-session-estimate.md) adds the omitted processing, transfer, compute, disk, state, audit, and lifecycle-address costs. Package downloads have their own assumed allocation; the old 100 MiB interactive-test target is not the total. Reconcile those quantities and account-currency SKUs against the BRL 300 cumulative ceiling before approval. The BRL planning envelope is not an account-specific billing quote.

Sources: [Load Balancing pricing](https://cloud.google.com/load-balancing/pricing), [Cloud NAT pricing](https://cloud.google.com/nat/pricing), and [network pricing](https://cloud.google.com/vpc/network-pricing). This active profile is not eligible for the earlier whole-exercise conditional zero-cost estimate, even if its VM-hours are covered by Free Tier.

## Resource selection

Owner confirmation (2026-10-02): use non-Spot `e2-micro` for the temporary lab probes in `us-central1`. This confirms the machine choice for planning, not deployment or verified Free Tier coverage. Retain the proposed 10 GB `pd-standard` disks and bounded test runtime; reassess any uncovered cost before deployment rather than silently changing machine type.

Compare effective cost after available allowances, resource capacity, and the complete deployment lifetime. The lowest VM list price alone does not determine the lowest total cost.

For `us-central1`, the published on-demand compute-only rates checked on 2026-10-02 are USD 0.0076/hour for `f1-micro` (0.60 GiB memory) and USD 0.008376428/hour for `e2-micro` (1 GiB memory). These exclude disks, network resources/traffic, and premium licenses. `f1-micro` has the lower list price in this comparison; this is not a claim about all machine types or purchasing models. [Compute pricing](https://cloud.google.com/products/compute/pricing/general-purpose).

The current Compute Free Tier covers eligible `e2-micro` usage, not `f1-micro`. Keep `e2-micro` as the initial probe choice while verified allowance covers the exercise; otherwise compare suitable alternatives, including `f1-micro`, before deployment. [Free Tier terms](https://docs.cloud.google.com/free/docs/free-cloud-features).

Public prod ingress, internal dev ingress, and NAT package egress are now selected in ADR 0004. Their active-profile costs are separate from the historical private-probe baseline below. VM allowances do not cover these networking services.

## Historical private-probe baseline — not the active LB topology

The four-hour figures below record the superseded proposal only. They must not be used as deployment limits after the owner's one-hour direction on 2026-10-03.

| Component | Planned configuration and usage | Published allowance or treatment |
| --- | --- | --- |
| Temporary probes | Up to three non-Spot `e2-micro` Linux VMs in `us-central1`, at most 4 hours each for the initial exercise: 12 aggregate VM-hours | Eligible usage up to the number of hours in the month; aggregate eligible instances/regions, not one allowance per project |
| Boot disks | Three 10 GB zonal `pd-standard` disks, deleted with their probes after the test; no snapshots | 30 GB-months of eligible standard persistent disk |
| Terraform state | Three regional Standard GCS buckets in `us-central1`; target at most 0.5 GB-months total including live, noncurrent, and soft-deleted objects | 5 GB-months; 5,000 Class A and 50,000 Class B operations per month in eligible regions |
| State operations | Planning allocation of at most 500 Class A and 5,000 Class B operations per month across all three buckets | These are internal planning allocations, not enforced request caps |
| Central audit copies | Target at most 1 GiB/month of selected administrative events in management, retained for 30 days | Ordinary Logging allowance is 50 GiB per project per month; source allowances do not combine into management's allowance |
| Administration | Standard IAP TCP forwarding and OS Login, no premium IAP features, no external VM addresses | Standard IAP access features have no IAP feature charge; compute and applicable traffic are still counted |
| Data transfer | Small SSH output and state transfers; planning target below 100 MiB outbound per relevant service meter for the exercise | Evaluate the applicable product, route, destination, and remaining allowance separately |

Compute/disk limits and their accounting basis come from the [Free Tier terms](https://docs.cloud.google.com/free/docs/free-cloud-features). Storage limits and retained-object billing come from [Cloud Storage pricing](https://cloud.google.com/storage/pricing). Eligible Compute and Storage usage is shared at billing-account scope; creating two more projects does not multiply those allowances.

Ordinary Logging storage beyond its free allotment is listed at USD 0.50/GiB with up to 30 days included. Copies of `_Required` events in a custom bucket count toward destination storage; they do not inherit the source bucket's free-storage treatment. Keep VPC Flow Logs and Firewall Rules Logging disabled for this exercise because their telemetry pricing differs from ordinary audit logging. [Observability pricing](https://cloud.google.com/products/observability/pricing).

The standard IAP feature selection excludes Chrome Enterprise Premium capabilities. Check applicable network usage independently. [IAP pricing](https://cloud.google.com/iap/pricing), [network pricing](https://cloud.google.com/vpc/network-pricing).

## How to evaluate fit before deployment

Use a ledger for the current billing month: published allowance, already consumed usage, expected usage by other resources before month-end, lab allocation, and remaining headroom. Verify the correct accounting scope for every product. Keep real account identifiers and billing exports outside the repository.

For the active baseline, the upper allocation is `3 × 1 = 3 VM-hours`, plus any extra VM/replacement time within the same session. The monthly allowance reference is calendar-dependent; do not assume a fixed 730 hours or three independent full-month VMs. Repeated tests consume the same available allowance and portfolio budget.

For standard disks, `3 × 10 GB × 1 hour` is 30 GB-hours, before extra scaling/replacement disks. Divide by the hours of the actual month for the GB-month estimate; even using a 28-day month, the baseline is below 0.045 GB-months. This assumes verified disk deletion within the session. Stopping VMs while retaining disks does not satisfy that assumption.

For storage and logs, count existing usage, retained versions, soft-deleted objects, duplicate copies, and operations. The three state buckets share the storage/operation allowances. Logging is checked per receiving project, including its other billable log storage. Keep all selected regional resources in `us-central1` and consider using one zone for temporary probes, subject to capacity, to simplify transfer accounting; no zonal-resilience claim is made.

If each selected SKU and transfer category is eligible and the remaining allowances cover the complete baseline usage, its **conditional incremental estimate is USD 0**. This is not a requirement for every exercise. If coverage is insufficient or a requirement calls for billable services, include their expected cost in the deployment proposal and compare reducing usage with paying for the justified configuration. Resource substitutions must remain explicit and costed.

## Controls and limitations

- Pin the machine family/type and disk type explicitly in future Terraform. Select a supported Linux image with no premium license fee and enough disk space for the 10 GB plan; reassess if the image requires more.
- Retain state isolation and the 7-day noncurrent-version recovery objective. Keep version/soft-delete volume within the allocation; do not erase active state to meet a storage target.
- Use the implemented bounded execution/cleanup tooling only after approval and attended validation. Its detached local timeout and read-only inventory checks are not an instantaneous billing cap or a host-independent shutdown mechanism.
- Keep the initial private-probe baseline small. Add billable networking or other features when they serve an explicit requirement, with a cost estimate and cleanup plan; they are not categorically excluded.
- Budget notifications supplement resource inventory and usage checks; they do not provide an immediate hard spending stop in this design. Billing delay can hide recent consumption.
- Remove probe VMs, disks, temporary rules, and test grants promptly. Track retained state and logs until their cleanup/retention requirements are satisfied.

The historical profile supported the initial 14 planned checks. The active Nginx/LB topology adds distribution, failure, and manual scaling checks V-15 through V-17 and changes the relevant flow tests. If an `e2-micro` cannot run a test reliably, record the limitation and reassess sizing. Deployment readiness still requires remaining-allowance verification, a complete active-profile estimate, and the owner's deployment authorization.
