# 0008: Basic application scope, backups, and Google-maintained modules

Superseded in part by [ADR 0009](0009-single-project-owner-operated-lab.md): the owner withdrew the module preference and confirmed a single dev workload project. Network/snapshot requirements remain; module migration is no longer required.

Status: Accepted direction; architecture simplification and remote-module migration pending. No deployment authorized.

## Context

After consolidating the case, the owner requested a simpler project-level monolithic VM scenario, retaining a load balancer, multiple backends, and manual scaling. Reserved addresses, explicit firewall rules, and recurring snapshots are required. The owner executes every Terraform plan and apply. Google-maintained modules take priority across the portfolio.

## Decision

Target one workload project, VPC/subnet, global external Application LB, two private Nginx replicas across two zones, and bounded manual scaling to three and back. Nginx is a synthetic monolith fixture. Organization governance and centralized audit are outside this target. Preserve the applied seed and recovery state; changing its access remains a separate owner-executed operation.

Reserve the external frontend and regional NAT addresses while private backends install packages through NAT. Do not fix individual MIG VM addresses: replicas are replaceable. The legacy internal frontend keeps its reservation until that topology is removed. NAT remains an explicit current-code dependency with cost, not a free implicit service.

Restrict backend HTTP to Google LB/health-check sources, SSH to IAP, and package egress to TCP 80/443; deny other backend ingress/egress. Legacy internal ingress also permits its proxy subnet. Stateful replies and platform metadata/DNS behavior are distinct from ordinary internet egress.

Attach a daily disk snapshot policy through the instance template so new replicas inherit it. Initial lab settings: 04:00 UTC (01:00 Fortaleza), one-day retention, storage in `us-central1`, no guest flush, and retention applied after source disk deletion. These are crash-consistent disk backups, not VM memory, full VM configuration, or application-consistent database backups. IaC remains the primary recovery method for stateless Nginx.

Evaluate Google-maintained module families `terraform-google-modules/network/google`, `terraform-google-modules/vm/google` (template/MIG), and `terraform-google-modules/lb-http/google`. These are candidates, not selected/downloaded versions. Direct resources may remain for snapshot schedules or address/firewall controls when justified. Follow the [portfolio standard](../../../cloud-infrastructure-portfolio/docs/portfolio-standards.md#terraform-module-selection).

## Alternatives Considered

- Fixed IPs per replica: unnecessary coupling for a scalable group; reserve service endpoints instead.
- Custom snapshot cron and backup identity: unnecessary alongside native Compute Engine schedules.
- Long backup retention: outside the disposable lab requirement.
- Immediate wholesale module replacement: rejected until compatibility, defaults, and ownership are reviewed.
- Keeping custom modules without evaluation: inconsistent with the owner's preference.

## Consequences

Local code includes the snapshot policy and explicit ingress denial alongside existing reservations/firewalls. Legacy dev/prod roots, NAT, provisioner impersonation, and bootstrap dependencies still exist. This is not the completed simplified module-based design. Do not apply historical plans or treat the old bootstrap plan as the next recommended deployment.

Generated snapshots are outside Terraform state. Destroying schedules/disks does not immediately remove snapshots. Inventory includes policy-labelled snapshots and resource policies; cleanup stays incomplete while lab snapshots remain. Manual test snapshots must carry the same backup-policy label. The owner must inspect exact targets and remove residual lab backups or explicitly approve retained-cost reserves, never sweep unrelated backups.

The one-hour session may produce no scheduled snapshot. Do not extend it waiting for a daily job. An owner-executed on-demand snapshot/restore can test recovery but does not prove scheduling; report separately. Retention is not a hard one-day deletion deadline. Include snapshots, restoration disks, and retained external IPs in a refreshed estimate before deployment; the prior estimate does not cover this addition. The cumulative BRL 300 ceiling and one-hour session including cleanup remain unchanged.

## Trade-offs

Snapshots demonstrate recovery controls but add little unique protection to stateless replicas and leave costs outside Terraform state. Maintained modules reduce custom code but require version/default review. Simplicity does not justify unrestricted access or unprotected state.

## References

- [Google module catalog](https://docs.cloud.google.com/docs/terraform/blueprints/terraform-blueprints)
- [Snapshot schedules and retention](https://docs.cloud.google.com/compute/docs/disks/about-snapshot-schedules)
- [Provider resource policy](https://registry.terraform.io/providers/hashicorp/google/8.5.0/docs/resources/compute_resource_policy)
