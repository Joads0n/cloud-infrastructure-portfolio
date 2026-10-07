# Cloud Security Architecture

**Status: Planned.** Folder scaffold only; no implementation, deployment, or validation results are claimed.

Intended focus: workload identity and least privilege, secrets/data protection, hardening, threat considerations, detection, and security-control validation. Define a distinct fictional scenario and acceptance criteria before implementation.

## Dependencies and boundaries

[Network Architecture](../gcp-secure-network-architecture/README.md) separately owns network design and its future network controls; this case supplies threat scenarios and can validate isolation without claiming ownership of the same firewall resources. [Governance](../cloud-governance-framework/README.md) defines policy and evidence requirements. [Enterprise Foundation](../gcp-enterprise-foundation/README.md) owns future organizational enforcement, while the current [Landing Zone](../gcp-enterprise-landing-zone/README.md) keeps seed/bootstrap IAM and audit ownership.

Expected evidence includes a threat model, justified control choices, positive/negative access tests, detection observations, and recovery/cleanup procedures. These artifacts do not exist yet. Do not equate local tests with live enforcement or certification. See the [ownership decision](../cloud-infrastructure-portfolio/docs/decisions/0002-case-boundaries-and-resource-ownership.md).

## Structure

- `docs/`: requirements, architecture decisions, and evidence when available.
- `infra/`: Terraform only when justified by the case requirements.
- `tests/`: validation suites when needed.

## Next milestone

Define the scenario, scope, constraints, and validation plan using the [common standards](../cloud-infrastructure-portfolio/docs/portfolio-standards.md). Document expected cloud cost and cleanup before provisioning. All cases share the BRL 300 cumulative portfolio ceiling.
