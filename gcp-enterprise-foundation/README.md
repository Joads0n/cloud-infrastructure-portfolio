# GCP Enterprise Foundation

**Status: Planned.** Scope definition only; no Terraform implementation, organizational deployment, or validation evidence exists yet. The current personal lab has no GCP organization available.

## Objective and scope

Design an organization-wide foundation for the fictional Cedar Route Logistics company: folder/project hierarchy, administrative IAM boundaries, organizational guardrails, naming and label enforcement where supported, and shared audit-service placement.

The [Governance case](../cloud-governance-framework/README.md) defines policy intent, exceptions, and evidence requirements; this case implements the approved organizational controls. Compliance means traceable control evidence, not a certification or an assertion that every requirement is satisfied.

## Dependencies and ownership

- Live organizational tests require a suitable organization, reviewed administrative access, a cost assessment, and separate deployment approval. Start with design and local tests when implementation exists; mark cloud enforcement as not executed until those prerequisites are met.
- The [Landing Zone](../gcp-enterprise-landing-zone/README.md) remains responsible for the existing project-level seed/bootstrap. This new case does not adopt its projects, identities, audit bucket, or state.
- A management project is not a substitute for an organization. Introducing an organization later requires an explicit hierarchy and ownership review, not automatic resource migration.

## Expected evidence — not yet produced

Hierarchy and trust-boundary diagrams; a control-to-enforcement matrix; architecture decisions and alternatives; local policy/configuration tests; and, when possible, positive/negative organization-policy tests with sanitized results and recovery instructions.

## Next milestone and operating limits

Define a small set of fictional organizational requirements and identify which need real organizational access. Do not create implementation-only folders until there is justified code to place in them.

All work shares the cumulative BRL 300 portfolio ceiling. Any paid trial must have an estimate, a bounded execution/cleanup plan, and explicit retention decisions. No provisioning is authorized by this README. See the [case ownership decision](../cloud-infrastructure-portfolio/docs/decisions/0002-case-boundaries-and-resource-ownership.md) and [catalog](../cloud-infrastructure-portfolio/README.md).
