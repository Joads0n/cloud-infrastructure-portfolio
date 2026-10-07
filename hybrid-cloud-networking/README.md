# Hybrid Cloud Networking

**Status: Planned.** Scope definition only; no VPN, routing appliance, external network, or connectivity experiment has been deployed or validated.

## Objective and scope

Demonstrate connectivity between a fictional on-premises network and GCP: address planning across boundaries, encrypted tunnels, route exchange, failure diagnosis, and controlled failover. Candidate technologies include VPN and BGP; the exact topology remains a design decision.

If the peer runs in a lab or cloud VM, label it **simulated on-premises**. Do not claim experience with a physical datacenter, dedicated circuit, or a second cloud provider from a cloud-to-cloud simulation.

## Dependencies and ownership

- [Network Architecture](../gcp-secure-network-architecture/README.md) supplies address/routing conventions and the agreed attachment boundary.
- [Landing Zone](../gcp-enterprise-landing-zone/README.md) supplies project prerequisites. Organization-wide resources, if needed, remain with [Enterprise Foundation](../gcp-enterprise-foundation/README.md).
- This case will own its dedicated hybrid gateways, tunnels, routing sessions, and peer fixture. Any shared network attachments need an explicit owning root before implementation; never mutate another case's resources outside its IaC.

## Expected evidence — not yet produced

Topology and route-advertisement diagrams; a sanitized route inventory; baseline reachability and isolation tests; observed behavior during a controlled tunnel/session failure; recovery measurements; troubleshooting notes; and teardown verification.

## Next milestone and operating limits

Choose an accessible peer simulation and estimate the complete topology, including both ends, addresses, traffic, and idle time. Evaluate whether provisioning, failure testing, and cleanup can fit one hour before approving the trial; reduce scope or request a revised plan if not.

Prepare and test locally where possible. All charges share the cumulative BRL 300 portfolio ceiling, not a separate hybrid budget. See the [ownership decision](../cloud-infrastructure-portfolio/docs/decisions/0002-case-boundaries-and-resource-ownership.md).
