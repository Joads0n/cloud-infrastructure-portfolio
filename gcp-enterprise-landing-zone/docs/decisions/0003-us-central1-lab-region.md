# 0003: Use us-central1 for regional lab resources

Status: Accepted for architecture planning by owner direction. Deployment and spending remain unauthorized.

Date: 2026-10-02

## Context

The owner selected `us-central1` for the three-project lab, with cost as the main driver. The case uses fictional data and temporary validation endpoints; it has no agreed Brazilian data-residency or end-user latency requirement. The architecture needs a consistent location for environment subnets, Terraform state, and central audit storage.

The published Free Tier includes eligible `e2-micro` usage and Cloud Storage usage in `us-central1`, `us-east1`, and `us-west1`, subject to their limits. Eligibility does not establish that the complete lab is free or that this region is uniquely cheapest. No account entitlement or remaining allowance has been verified. [Free Tier terms](https://docs.cloud.google.com/free/docs/free-cloud-features).

## Decision

Use `us-central1` (Iowa) for both environment subnets, all three regional GCS state buckets, and the custom central Cloud Logging bucket. Temporary VMs and their zonal disks will use a zone within this region, selected after confirming machine availability and quota. Projects and VPC networks are not assigned a region by this decision.

Select a regional location for each new bucket explicitly; do not substitute the `US` multi-region. Leave existing project resources and platform-created log buckets unchanged. The chosen region supports the intended regional storage and logging locations. [Cloud Storage pricing by location](https://cloud.google.com/storage/pricing), [Cloud Logging locations](https://docs.cloud.google.com/logging/docs/region-support).

Document the rationale as an owner-selected region for a cost-conscious lab, not as a proven global price minimum. The owner clarified that right-sized resources and recurring Free Tier allowances are preferred, while justified public IPs, global load balancing, NAT, and other billable resources are acceptable. The [cost plan](../proposals/gcp-landing-zone-cost-plan.md) gives only the initial private-probe profile a conditional USD 0 incremental estimate, not a zero-cost-only constraint. Include VM runtime, disks, state versions/operations, central log storage, and all applicable network resources and traffic; do not rely on unverified Free Trial credits. Quantify uncovered usage before deployment authorization.

## Alternatives Considered

- **us-east1 or us-west1:** also included in the cited Free Tier locations. They remain viable alternatives; no complete bill comparison establishes a unique cheapest region.
- **southamerica-east1:** relevant if a future workload requires Brazilian data location or latency validation. Those requirements are not part of this synthetic lab; revisit location when they arise.
- **Multiple regions:** useful for a separate regional-recovery objective, but the current tests do not require that topology or its additional deployment and evidence scope.

## Consequences

The planned regional resources share one location, simplifying the deployment inventory and cost model. Temporary compute still needs a zonal placement decision and quota/capacity checks. Regional colocation does not imply that all traffic is free or that existing audit data is relocated.

Lab data and regional state are stored in the United States. This lab does not demonstrate Brazil-specific latency, a Brazilian residency requirement, or recovery from loss of the selected region. The proposed configuration-recovery exercise assumes required platform resources remain available.

## Trade-offs

The decision favors a small, repeatable lab scope. It accepts a single-region failure domain and leaves real workload location requirements for a later design. Change the decision if the selected services, dated estimate, quota availability, or approved requirements make another region more suitable.

Before apply, validate region/zone and bucket-location inputs against this ADR and record dated costs using the official [Compute Engine](https://cloud.google.com/products/compute/pricing), [Storage](https://cloud.google.com/storage/pricing), [Observability](https://cloud.google.com/products/observability/pricing), and [network](https://cloud.google.com/vpc/network-pricing) pricing sources. No bill estimate or cloud validation is claimed by this decision.
