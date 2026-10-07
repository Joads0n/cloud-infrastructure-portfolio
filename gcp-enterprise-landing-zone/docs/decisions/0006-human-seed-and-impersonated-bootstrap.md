# 0006: Human-operated seed and impersonated foundation bootstrap

Status: Local implementation authorized by the owner; cloud deployment remains unauthorized.

Date: 2026-10-03

## Context

The owner will execute Terraform from a personal user session and requested that Terraform also create the bootstrap service account. The previous implementation used the user's administrative credentials directly for foundation operations. A provider cannot authenticate as a service account that has not yet been created and authorized. The three projects already exist; no project creation, recreation, or billing changes are needed.

## Decision

Use a separate `infra/seed` root with human Application Default Credentials (ADC). Seed alone owns the 22 required project/API entries, `crl-tf-bootstrap` in management, its project grants, and the named user's Token Creator grant on that account. It creates no keys, buckets, projects, or compute resources. Existing API ownership moves from the unexecuted bootstrap configuration; do not apply this refactor to deployed state without a separate migration review.

Keep seed state local on an encrypted trusted workstation, with restrictive permissions and an independently protected recovery copy. Do not place it in a bootstrap-controlled bucket: the identity responsible for creating and recovering bootstrap must not depend on that same bootstrap identity or backend. Retain only the three existing foundation state buckets; this decision adds no cloud-hosted state bucket.

Set `bootstrap_access_enabled=false` by default. An approved seed apply with `true` enables the identity and grants reviewed access. After foundation validation and backend migration, a human-operated seed apply with `false` disables the identity and removes seed-managed grants and impersonation. This is an explicit maintenance procedure, not an automatic expiry or a substitute for inventory review. Human credentials are still needed for later seed maintenance/recovery, not ordinary workload applies.

The bootstrap provider derives and explicitly impersonates `crl-tf-bootstrap` in the supplied management project. Its GCS backend configuration must explicitly use the same identity; provider authentication does not configure backend authentication. Bootstrap owns environment identities/IAM, state buckets, and central audit routing, but no APIs or bootstrap identity/grants. Workload providers/backends continue using their separate environment provisioners.

Use predefined roles with documented scope. In management, grant Storage Admin, Logging Admin, and Service Usage Consumer, plus conditional Project IAM Admin restricted to `roles/logging.bucketWriter` project bindings. Do not grant management Service Account Admin or unrestricted management project IAM administration. In dev/prod, grant Service Account Admin, Project IAM Admin, Logs Configuration Writer, and Service Usage Consumer. Do not grant Owner, Editor, key administration, or organization roles.

## Alternatives Considered

- Keep the user's broad credentials for all foundation operations: simpler, but does not provide the requested dedicated execution identity.
- Manually create a bootstrap account or download its key: rejected; seed records ownership in IaC and impersonation avoids persistent service-account keys.
- Create and impersonate the bootstrap account in the same first provider execution: rejected because credentials must exist before provider operations begin.
- Store seed state in a bootstrap-created bucket: rejected as the default because it couples recovery to the identity and backend being recovered.
- Give bootstrap unrestricted management IAM access: rejected; only sink-writer grants are required there. Dev/prod IAM remains administrative because bootstrap creates and grants environment identities; no narrow security boundary is claimed for those projects.

## Consequences

There are four runnable roots: seed, bootstrap, dev, and prod. APIs have one owner and remain enabled on retirement. Bootstrap plans now fail if the seed identity, permission grants, or impersonation are unavailable; there is no intended fallback to the user's Owner permissions. Verify effective identity and inherited grants during the first authorized live trial.

Seed's administrator must already be authorized to enable APIs, create the management service account, and manage the reviewed IAM grants across the three isolated projects. Terraform does not grant that user's initial authority. IAM propagation, organization constraints, ADC quota-project permissions, and Compute service-agent grants require cloud verification. Mock tests are not evidence that IAM conditions are enforced or permissions are sufficient.

All seed/bootstrap operations, state copies, logs, failures, and maintenance remain inside the BRL 300 cumulative portfolio ceiling and existing lifecycle review. No additional always-running cloud service is introduced. Record the first seed apply and use it as the conservative start of the foundation's 30-day review period, rather than extending retention by delaying bootstrap. Workload cleanup still targets one hour and excludes seed/bootstrap.

## Trade-offs

Root ownership is not a general security boundary. Management Storage Admin covers all state in that project, and Logging Admin can read and modify its logs. Dev/prod Project IAM Admin can grant additional roles, including to bootstrap itself, and Service Account Admin controls environment identities. Do not use these grants in projects containing unrelated resources. Revoking the seed-managed grants does not discover or revoke any extra access created outside this configuration; reconcile effective IAM and existing tokens before claiming revocation is complete.

The management condition limits roles, not recipient identities, and inherited unconditional grants can bypass it. Protect seed code, local state, the human account, and recovery copies. The local recovery copy does not provide remote locking or protection against workstation loss; this is a single-operator lab, not a team production bootstrap.

References: [Terraform authentication](https://docs.cloud.google.com/docs/terraform/authentication), [limited IAM administrators](https://docs.cloud.google.com/iam/docs/setting-limits-on-granting-roles), [service-account IAM administration](https://docs.cloud.google.com/iam/docs/manage-access-service-accounts), [GCS backend authentication](https://developer.hashicorp.com/terraform/language/backend/gcs).
