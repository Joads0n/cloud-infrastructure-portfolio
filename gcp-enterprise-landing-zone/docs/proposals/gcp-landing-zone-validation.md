# Multi-Project Foundation Validation Plan

Historical multi-project proposal. Superseded by the [single-project architecture](../single-project-architecture.md) and its runbook. Old resource counts, deployment commands, estimates, and validation status below are not the current baseline.

Status: the 17 acceptance checks below remain **planned, not completed**. Separate seed preflight/apply verification was executed on 2026-10-03: active projects/billing, human identity and seed permissions, successful apply, empty post-apply plan, and bootstrap token generation. This is not proof of the broader isolation/runtime checks; see the seed execution record (arquivo histórico na recuperação privada; fora da entrega pública). This plan accompanies the [architecture](gcp-landing-zone-architecture.md) and [requirements](gcp-landing-zone-requirements.md). It authorizes no cloud deployment or destructive experiment.

## Preconditions

Before cloud tests, confirm project suitability, effective permissions, project/billing scope, approved estimate, test duration, and teardown owner. Use only disposable lab fixtures. Record a configuration revision and the logical identity used for each test without publishing credentials or real identifiers.

Apply the [cost-aware usage plan](gcp-landing-zone-cost-plan.md): verify headroom including other projects and include LB/NAT charges before deployment authorization. Available resource quota is not a remaining free allowance. The current topology is the [Nginx ingress slice](../../infra/README.md), replacing the former private-probe exercise. Local Terraform tests are distinct from the unexecuted cloud checks below.

Negative IAM checks must use dedicated, restricted credentials, not an Owner account or a session that can silently fall back to it. Confirm the active principal and intended target privately before each check. A failure caused by disabled APIs, expired credentials, or a nonexistent target is not proof of least privilege.

For the two-stage foundation, privately verify seed uses the reviewed human ADC, bootstrap provider/backend both impersonate the seed-created identity, and APIs have only seed ownership. Review the management project IAM condition and inherited grants using effective-policy analysis; do not attempt to grant Owner as a test. After foundation reconciliation, apply the reviewed seed disable plan and verify account disablement, removal of seed-managed grants, and failure to obtain new bootstrap credentials, while workload credentials still function. Seed state must remain independently recoverable. These are additional foundation preconditions, not checks already completed by local mocks. See [ADR 0006](../decisions/0006-human-seed-and-impersonated-bootstrap.md).

For network checks, confirm endpoint health, the listening port, and a permitted control path. Distinguish absence of a route from firewall denial. Do not add cross-environment connectivity merely to make a denied-path test possible.

## Checks and acceptance evidence

| Test | Requirement | Method and expected result | Evidence boundary |
| --- | --- | --- | --- |
| V-01 | GOV-01 | Reconcile three logical projects and all lab resources against ownership, purpose, environment, and cost metadata; document resources that do not support labels | Inventory and Terraform configuration review first; actual resource reconciliation after deployment |
| V-02 | SEC-01 | With the dev Terraform identity, read an allowed dev network and attempt the equivalent operation on an existing prod network; dev succeeds, prod is denied. Repeat with the prod identity in reverse | Verify identity and target existence; record effective grants relevant to the action |
| V-03 | SEC-01, IAC-01 | Each environment identity reads/writes a disposable test object in its own backend bucket and cannot read a known test object in the opposite or bootstrap bucket | Use fixture objects, never alter actual Terraform state for this access test |
| V-04 | SEC-01 | Review provisioner permissions for project IAM updates, role grants, key creation, and privileged impersonation; execute only a harmless approved denial check | Do not try a privilege-grant mutation against a privileged identity as a test |
| V-05 | NET-01 | From the dev VM, reach the internal frontend using the fictional Host name; verify local Nginx and LB health; no public path to dev | Positive control for private HTTP ingress, not a two-client or HA test |
| V-06 | NET-01 | Dev-to-prod and prod-to-dev private TCP connections fail while endpoints are healthy; verify no interconnection and no unintended allow path | Demonstrates absence of the tested network path; does not alone prove all firewall behavior |
| V-07 | NET-01, SEC-02 | Confirm package downloads via NAT on TCP 80/443; attempt a disallowed port on a controlled healthy destination and inspect effective rules | Port restrictions do not demonstrate domain filtering; distinguish policy failure from missing route |
| V-08 | SEC-02 | Authorized operator opens SSH through IAP/OS Login; a scoped unauthorized identity is denied; VM interfaces have no external addresses; only prod has an external LB frontend | A public LB is intentionally allowed, but direct VM/SSH exposure is not |
| V-09 | OBS-01 | Make a reversible description change on a disposable lab resource in each environment, then find its new audit event centrally with correct logical source and action | Sink must already be active and authorized; use bounded retries and record failures, not fabricated event output |
| V-10 | OBS-01, SEC-01 | Audit reviewer can query the intended central view; ordinary environment operator cannot administer the central destination; review sink writer permissions for write-only purpose | Read access and configuration access are separate; destructive deletion is not a validation method |
| V-11 | IAC-01 | Format, validate, lint, and scan configuration after it exists; review separate roots and ensure a dev plan contains no prod resource change | Local validation cannot establish effective cloud access or a successful apply |
| V-12 | IAC-01 | Verify backend migration and a no-change plan; demonstrate locking against an isolated fixture state using a non-applying operation | Never hold or break a real production lock; record fixture cleanup |
| V-13 | REL-01 | Recover a previous state generation in an isolated recovery fixture, verify lineage/serial and reconcile with known resources; record elapsed time against the proposed 8-hour target | Do not overwrite the current environment state; an isolated exercise does not prove recovery from project/account loss |
| V-14 | FIN-01 | Compare the approved estimate with deployed resources and observed usage; remove fixtures and reconcile retained state versions, logs, disks, and any soft-deleted objects | Billing can arrive later; record observation time and residual costs instead of claiming immediate zero spend |
| V-15 | NET-01, REL-01 | Confirm both prod backends are healthy across two zones; send bounded HTTP requests and observe both anonymous tokens | No strict round-robin or exact traffic ratio claim; record sample and health state |
| V-16 | REL-01 | Stop Nginx on one authorized disposable prod VM; observe failed health checks and service from the surviving backend; restart and confirm recovery | Record detection interval and transient errors; no zone-outage or zero-downtime claim |
| V-17 | REL-01, FIN-01 | With an approved extra-VM window, change prod size 2 → 3 → 2 using reviewed Terraform plans; observe membership, health, and cleanup | Demonstrates manual horizontal scaling, not autoscaling |

## Minimal temporary fixtures

Plan for one dev Nginx VM and two prod Nginx VMs, using non-Spot `e2-micro`, 10 GB `pd-standard` disks, and no VM external addresses. All provisioning, tests, optional third-VM scaling, and verified workload cleanup must fit within one shared one-hour session. Start teardown by minute 40 or earlier and skip remaining tests if setup runs late; do not silently extend the session. Boot installs Nginx using NAT. A static fictional page and random backend tokens replace a business application. Delete disks and billable networking during cleanup; stopping instances is insufficient. Confirm timeout/failure-cleanup readiness and the cumulative BRL 300 portfolio ledger before a run. See the [runtime procedure](../../infra/README.md).

Probe creation, temporary firewall rules, operator access, runtime identities, and disks must be inventoried together. The administrator verifies the prod endpoint locally through its separately authorized management path before using a failed cross-environment connection as evidence.

## Evidence and cleanup record

For each test, record: requirement/test ID, configuration revision, date, logical actor and target, method, expected result, observed result, status, evidence reference, limitations, and cleanup outcome. Use **passed**, **failed**, or **not executed** only after attempting or explicitly deferring the check.

Published examples must be wholly fictional. Actual execution evidence may be summarized as a reviewed observation, but do not commit raw output, project IDs, principal addresses, keys, tokens, or Terraform state. Synthetic example output must be marked illustrative and must never be presented as a passed runtime test.

If any check fails, preserve the relevant private diagnostic evidence, record the limitation, and stop dependent checks where necessary. Tear down temporary fixtures even when the validation fails. Follow the architecture's dependency order and preserve backend access until teardown has been reconciled.
