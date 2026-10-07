# 0004: Internal development and external simulated-production application ingress

Status: Accepted for local implementation by owner direction, 2026-10-02. On 2026-10-03 the owner set a BRL 300 cumulative portfolio ceiling and test-only sessions of at most one hour, including provisioning and cleanup. Cloud deployment, the complete session estimate, and enforcement controls remain pending.

## Context

The owner requested an internal development load balancer, a global external Application Load Balancer for simulated production, a static Nginx page, and two production backends to demonstrate traffic distribution and scaling. The earlier private-probe baseline did not exercise application ingress. Private development exposure is this fictional company's policy, not a universal property of development environments.

## Decision

- Dev: a regional internal Application Load Balancer (`INTERNAL_MANAGED`), one `e2-micro` Nginx backend, workload subnet `10.80.10.0/24`, proxy-only subnet `10.80.20.0/23`, and internal frontend `10.80.10.10`.
- Prod: a global external Application Load Balancer (`EXTERNAL_MANAGED`, Premium Tier), a regional managed instance group (MIG) initially containing two `e2-micro` Nginx VMs across `us-central1-a` and `us-central1-b`, and workload subnet `10.90.10.0/24`. This is one backend service with two backend VMs, not two separate applications.
- Both environments: private VM interfaces, 10 GB standard persistent boot disks, OS Login/IAP administration, explicit backend firewall rules, `/healthz`, no CDN or application state. Separate environment roots own their own network, NAT, load balancer, and compute. Projects, API enablement, runtime identities, state buckets, and foundation audit routing are prerequisites, not created by this module.
- One Cloud NAT per environment supplies package installation and replacement-VM bootstrapping. Egress allows TCP 80/443, with other ordinary IPv4 traffic denied. This is port filtering, not domain-based repository allowlisting; NAT is not a security boundary. No peering or cross-project private route is introduced.
- Use reserved fictional names `dev.cedar-route.example` and `app.cedar-route.example`. Do not create public DNS zones or request publicly trusted certificates for them. Test with explicit hostname-to-address mapping (`curl --resolve`); use HTTP only for this disposable synthetic exercise. Prod planning requires an explicit `allow_public_http=true` acknowledgement. A real workload requires a separate HTTPS/domain decision.
- Start prod at two VMs. A separate, costed manual Terraform size change from two to three and back demonstrates horizontal scaling. No autoscaler or application autohealing is configured in this iteration, so stopping Nginx can isolate the load balancer's health behavior. A MIG still manages VM lifecycle; service failure and VM deletion are different experiments.

Official references: [internal Application LB configuration](https://docs.cloud.google.com/load-balancing/docs/l7-internal/setting-up-l7-internal), [global external Application LB](https://docs.cloud.google.com/load-balancing/docs/https/setup-global-ext-https-compute), [regional MIG placement](https://docs.cloud.google.com/compute/docs/instance-groups/distributing-instances-with-regional-instance-groups), and [reserved domain names](https://www.iana.org/assignments/special-use-domain-names/special-use-domain-names.xhtml).

## Alternatives Considered

- Internal passthrough Network LB: simpler L4 path, but not the same HTTP application-routing exercise as prod; an L7 internal LB better matches this requirement.
- A single prod VM: cheaper, but cannot demonstrate continued service from another backend when Nginx fails.
- Two unmanaged VMs: enough for distribution and failover, but a MIG also provides declarative manual resizing without duplicating VM definitions.
- Autoscaling now: deferred until load targets, test duration, and a resource ceiling are agreed; two existing VMs alone do not prove autoscaling.
- Public VM IPs for package downloads: avoid NAT charges, but dev/prod private backends give a clearer separation of ingress, administration, and egress. A prebaked image could remove download dependency later.

## Consequences

This replaces the private-probe topology as the next implementation target, not the broader IAM/logging/state requirements. Two prod VMs improve the testable failure tolerance but do not establish a production SLA, multi-region resilience, or zero interrupted requests during health detection. Small request samples need not alternate evenly between VMs.

Each VM exposes only a randomly generated lab token for distinguishing responses, never project IDs, IPs, metadata, or credentials. Nginx access logs and LB request logging are disabled initially; central administrative audit logging remains a separate foundation requirement. Runtime health, startup success, distribution, failover, and scaling still require cloud validation.

## Trade-offs

The internal LB incurs a minimum managed-proxy charge even without requests. NAT, addresses, LB processing, and transfers add costs outside the VM allowance; see the [revised cost plan](../proposals/gcp-landing-zone-cost-plan.md). Run bounded sessions and destroy billable networking too, not just VMs.

The low-cost MIG replacement policy uses zero surge and can replace all configured-zone instances concurrently; it does not promise uninterrupted template upgrades. HTTP is intentionally limited to fictional static content and does not demonstrate encryption. Exact OS image inputs are required, but package versions still follow signed Debian repositories at boot, so this is not a fully immutable image build.
