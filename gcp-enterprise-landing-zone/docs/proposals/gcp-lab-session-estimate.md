# Whole-lab planning estimate, including bootstrap

Historical multi-project proposal. Superseded by the [single-project architecture](../single-project-architecture.md) and its runbook. Old resource counts, deployment commands, estimates, and validation status below are not the current baseline.

Date: 2026-10-03. **Illustrative estimate, not a billing quote or deployment approval.** The owner's BRL 300 ceiling includes every resource, bootstrap, scenario, repeated/failed session, retention, and delayed charge. No Free Tier headroom or trial credit is deducted in this calculation.

## Assumed scope

One combined one-hour allowance for the proposed dev/prod topology, conservatively counting four VM-hours (one dev, two prod, and an optional extra prod VM counted for a full hour), four 10 GiB disks, two LBs, and two NAT gateways. This is an accounting envelope, not permission for a four-hour run. The controller executes one environment per attended session; if dev and prod are tested in separate sessions, estimate/reserve each run rather than reusing this envelope as an unlimited pass.

The retained foundation allowance is one 30-day review period: 0.5 GiB-month total state storage including versions, 500 Class A operations, 5,000 Class B operations, and 1 GiB of central audit ingestion. Package traffic through NAT is allocated 1 GiB; combined LB request/response processing 2 GiB; internet responses/state/admin traffic to South America 0.5 GiB; chargeable inter-zone traffic 0.5 GiB. These are synthetic planning quantities, not enforced quotas or measured consumption. Public request volume and download size can exceed them.

## USD calculation without free allowances

The two-stage seed/bootstrap flow adds no cloud bucket, VM, or continuously running service. Seed keeps independent protected local state. Include its administrative events and repeated maintenance in the existing foundation allowance and reconciliation; this is not a claim that its operation has no ancillary costs. Count the 30-day review period from the earlier seed apply under [ADR 0006](../decisions/0006-human-seed-and-impersonated-bootstrap.md).

| Item | Assumed quantity × reference rate | USD subtotal |
| --- | --- | ---: |
| `e2-micro` | 4 VM-hours × 0.008376428 | 0.033506 |
| Standard persistent disks | 40 GiB-hours × 0.000054795 | 0.002192 |
| Internal LB | 3 minimum managed proxies × 1 hour × 0.025 | 0.075000 |
| Global external LB forwarding | 1 hour × 0.025 | 0.025000 |
| LB processing | 2 GiB × 0.008 | 0.016000 |
| NAT gateways | 4 assigned VM-hours × 0.0014 | 0.005600 |
| NAT IPv4 addresses in use | 2 address-hours × 0.005 | 0.010000 |
| NAT processing | 1 GiB × 0.045 | 0.045000 |
| Reserved/unattached IPv4 allowance | 3 address-hours × 0.01, deliberately extra for lifecycle transitions | 0.030000 |
| Internet transfer to South America | 0.5 GiB × 0.19 | 0.095000 |
| Inter-zone transfer | 0.5 GiB × 0.01 | 0.005000 |
| Regional Standard state storage | 0.5 GiB-month × approximately 0.02 | 0.010000 |
| State Class A operations | 500 / 1,000 × 0.005 | 0.002500 |
| State Class B operations | 5,000 / 1,000 × 0.0004 | 0.002000 |
| Central audit ingestion, including 30-day storage | 1 GiB × 0.50 | 0.500000 |
| **Total before BRL planning factors** | Calculated using unrounded rates | **0.856798** |

Sources checked 2026-10-03: [Compute](https://cloud.google.com/products/compute/pricing/general-purpose), [disks](https://cloud.google.com/compute/disks-image-pricing), [load balancing](https://cloud.google.com/load-balancing/pricing), [NAT](https://cloud.google.com/nat/pricing), [network/addresses](https://cloud.google.com/vpc/network-pricing), [storage](https://cloud.google.com/storage/pricing), and [Logging](https://cloud.google.com/products/observability/pricing).

The external LB's attached frontend address has no separate in-use address charge; the extra unused-address allocation above is a conservative transition allowance, not a second normal in-use bill. Traffic meters overlap intentionally where both processing and transfer apply. Proxy expansion, additional VM replacements, excess traffic, and longer retention require recalculation. No DNS zone, domain purchase, certificate service, premium image, autoscaler, paid security subscription, or application database is deployed by this slice. Recheck the plan if any are added.

## BRL planning envelope — explicitly assumed, not a current FX quote

For sensitivity testing only, use **7 BRL per USD**, a **30% pricing/tax/currency buffer**, and **50% operational contingency**. These are invented planning factors, not the actual exchange rate or Brazilian tax rate:

`USD 0.856797512 × 7 × 1.30 × 1.50 = BRL 11.695286...`

Round this illustrative initial workload-plus-foundation envelope up to **BRL 15**, subject to review. This does not mean every future scenario costs BRL 15 or that 20 sessions fit safely in BRL 300. Billing in BRL uses the account's currency-specific SKUs, not necessarily spot FX. Confirm those rates and applicable charges privately before apply. The estimate cannot cap hostile public traffic or delayed cleanup.

For later sessions, separately account for workload use and the still-retained foundation; do not forget its cost and do not silently reset the budget every month. Keep a conservative retained-cost reserve in the private ledger. Reconcile actual billed cost against reservations before releasing any headroom. A lower bill from verified Free Tier coverage is a result to observe, not an assumed entitlement.

## Approval conditions

The owner accepted state/audit retention on 2026-10-03, with review/retirement within 30 days of first foundation (seed) apply and all costs inside the same BRL 300 cumulative ceiling. Deployment still requires current account-currency cost review, exact image/quota/API/IAM checks, a reviewed plan, durable access during cleanup, and acceptance of the local watchdog's host-failure limitation. The controller does not provision or automatically retire bootstrap. Bootstrap execution also needs an attended, bounded window and separate recovery review; retention acceptance does not authorize deployment. No cloud charge or runtime test has been measured in this repository.
