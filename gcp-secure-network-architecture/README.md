# GCP Secure Network Architecture

**Status: Planned.** Scope definition only; no standalone network lab has been implemented, deployed, or validated.

## Objective and scope

Design and test a network architecture for fictional Cedar Route Logistics workloads: non-overlapping address ranges, segmentation, routing, DNS, ingress/egress paths, and network firewall controls. Document which connections are allowed, denied, and observable, and why.

This is a separate case from [Security](../cloud-security-architecture/README.md) and [Governance](../cloud-governance-framework/README.md). Security supplies threat scenarios and control requirements; Governance supplies policy and exception rules; this case owns its network design and network-control implementation.

## Dependencies and ownership

- Reuse reviewed project-level prerequisites from the [Landing Zone](../gcp-enterprise-landing-zone/README.md) where appropriate, with private inputs and explicit permissions.
- The existing Nginx VPCs, subnets, firewall rules, NAT, and load balancers remain owned by the [Landing Zone case](../gcp-enterprise-landing-zone/README.md). This future network case does not duplicate their ownership.
- A future dedicated fixture needs explicit resource/state ownership. Reusing a module does not permit two states to manage the same resource.
- Cross-boundary VPN/BGP experiments belong to [Hybrid Networking](../hybrid-cloud-networking/README.md), with interfaces agreed before implementation.

## Expected evidence — not yet produced

An IP allocation plan, packet-flow diagram, routing and firewall decisions, positive/negative connectivity tests, DNS-resolution checks, failure diagnosis, and verified cleanup. Use synthetic endpoints and publish no real lab addresses or identifiers.

## Next milestone and operating limits

Define one communication matrix and a minimal test topology, then assess whether existing reusable code is sufficient. Do not create a separate `terraform-gcp-networking` case merely to repeat this implementation.

Prepare locally before any cloud trial. Resources, logging, traffic, retained artifacts, and cleanup share the BRL 300 cumulative ceiling; disposable trials must fit the approved one-hour window, including provisioning and cleanup. See the [ownership decision](../cloud-infrastructure-portfolio/docs/decisions/0002-case-boundaries-and-resource-ownership.md).
