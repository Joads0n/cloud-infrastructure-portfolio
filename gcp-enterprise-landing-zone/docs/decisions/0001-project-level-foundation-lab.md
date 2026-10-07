# 0001: Demonstrate the foundation in a single-project lab

Status: Superseded proposal; never implemented. See [ADR 0002](0002-multi-project-foundation-lab.md).

Date: 2026-10-02

The owner subsequently authorized planning two additional environment projects. The text below preserves the earlier alternative and its limitations; it is not the current implementation direction.

## Context

The owner approved the fictional Cedar Route Logistics scenario and confirmed a GCP project with billing, without an organization. Access scope and existing resources have not been inspected. The business scenario needs development/production boundaries and governance evidence, while the portfolio must distinguish intended enterprise controls from what its lab can demonstrate. No deployment spending is authorized.

## Decision

Propose a project-level lab with two custom VPCs, one subnet per simulated environment, no interconnection, existing project audit logging, and separate Terraform roots/state for bootstrap and environments. Keep the existing project, default network, IAM grants, and unrelated resources outside Terraform ownership.

Treat `prod` as a simulation. Explicitly document common project administration and the incomplete coverage of SEC-01. Evaluate organization hierarchy, Shared VPC, and independent security ownership as future reference-design topics. Describe coverage and evidence in the [architecture](../proposals/gcp-landing-zone-architecture.md).

Keep this planning ADR in the portfolio repository until the dedicated case repository is established. That repository should carry the reviewed decision and its implementation evidence.

## Alternatives Considered

- **Documentation only:** sufficient for initial reasoning but offers no path to runtime evidence using the project already available.
- **Multiple standalone projects:** better project-level separation without necessarily requiring an organization; adds project creation, access, and billing scope that the owner has not confirmed. Revisit when environmental isolation becomes a deployment requirement.
- **Organization-level foundation:** supports hierarchy, inherited controls, and Shared VPC, but organization access is unavailable. Do not make organization setup a prerequisite for this initial learning case.
- **One VPC with two subnets:** simpler topology, but the desired default lack of inter-environment connectivity would depend more heavily on firewall controls. Two VPCs make the planned network boundary explicit while retaining a small resource set.

## Consequences

The lab can support address planning, configuration review, eventual network tests, audit-event checks, and state-management evidence. It cannot by itself satisfy enterprise administrative separation, independent logging ownership, or organization governance requirements.

Existing project-wide permissions can reach both environments. Terraform state separation does not change that. Network and audit claims remain unvalidated until appropriate checks execute. Backend storage and optional test endpoints require cost estimation, authorization, and cleanup planning.

## Trade-offs

The reduced scope uses the available environment and limits initial resources, at the cost of partial enterprise-control coverage. The case remains a Cloud Infrastructure Engineering exercise; it must not be presented as a production-ready enterprise landing zone.

Review the decision when organization access becomes available, separate administrators require independent environments, or real workloads are considered. Before Terraform, resolve region, network controls, IAM checks, and state recovery details. Before deployment, confirm a suitable lab project and an agreed cost limit.

Validate coverage against GOV-01 through REL-01 in the [requirements brief](../proposals/gcp-landing-zone-requirements.md). Official references for platform constraints are linked beside the relevant architecture claims.
