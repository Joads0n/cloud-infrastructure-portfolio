# Cloud Governance Framework

**Status: Planned.** Scope definition only; no policy engine, enforcement workflow, or compliance result has been implemented or validated.

## Objective and scope

Define how fictional Cedar Route Logistics approves, checks, and reviews cloud standards: ownership, naming/labels, allowed deployment patterns, policy-as-code checks, time-bound exceptions, and evidence retention.

Keep a traceable mapping from each requirement to its control, enforcement point, responsible case, test, and observed result. A policy document or passing local test is not evidence of live cloud enforcement or regulatory certification.

## Dependencies and ownership

- [Enterprise Foundation](../gcp-enterprise-foundation/README.md) implements organization-level controls when its prerequisites exist. This case owns the rules, exception process, and validation artifacts, not a second copy of those cloud resources.
- [Landing Zone](../gcp-enterprise-landing-zone/README.md), [Networking](../gcp-secure-network-architecture/README.md), and [Security](../cloud-security-architecture/README.md) implement controls in their own scopes.
- Local CI checks can be designed independently of an organization. They gate submitted configuration; they do not prevent every out-of-band cloud change.
- [FinOps](../cloud-finops-lab/README.md) supplies cost-allocation and budget requirements. This case does not create a new portfolio budget or ledger.

## Expected evidence — not yet produced

A control catalog; compliant and deliberately noncompliant synthetic fixtures; reproducible policy-test results; a documented exception with owner, expiry, and review; and clear identification of preventive versus detective checks and their limitations.

## Next milestone and operating limits

Select a small initial policy set, such as required ownership labels and explicit review of public exposure. Choose tooling only after requirements and test fixtures are agreed.

Prefer local validation first. Any cloud work requires an estimate, separately approved execution, and cleanup/retention plans within the shared BRL 300 ceiling. See the [ownership decision](../cloud-infrastructure-portfolio/docs/decisions/0002-case-boundaries-and-resource-ownership.md) and [catalog](../cloud-infrastructure-portfolio/README.md).
