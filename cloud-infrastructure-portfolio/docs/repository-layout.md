# Folder layout and operational handoff

Updated: 2026-10-06. One Git repository, no nested repositories or submodules. The remote remains `Joads0n/cloud-infrastructure-portfolio`; the local workspace is `cloud-portfolio-catalog`.

## Ownership

| Location | Responsibility |
| --- | --- |
| Root README | Portfolio overview and navigation |
| `cloud-infrastructure-portfolio/` | Catalog, roadmap, standards, profile source and historical decisions |
| `gcp-enterprise-landing-zone/infra/vm-web-platform/` | Only active workload root: local state, human ADC, optional project creation/deletion, billing association, runtime identity, APIs and Compute resources |
| `gcp-enterprise-landing-zone/infra/vm-web-platform/templates/` and `tests/` | VM content and mocked Terraform plans |
| Root `.private/recovery/` (ignored) | Legacy source, seed/dev state, backups and old caches; removed from the public case on 2026-10-07 |
| `gcp-enterprise-landing-zone/tests/` | Python tests and Terraform suite index |
| Other case folders | Planned independent scenarios; no duplicate ownership of this workload |
| Root `.private/` (ignored) | Private inputs, saved plans/evidence, tool cache, recovery records and cumulative budget information |
| Root `AGENTS.md`, `.github/`, `.gitignore`, `.terraform-version` | Shared engineering, workflow, publication safety and CLI pin |

## Current operating paths

Run workload commands from the repository root with `-chdir=gcp-enterprise-landing-zone/infra/vm-web-platform`. Use the existing configured `terraform` command, not repeated PATH overrides. See the [current runbook](../../gcp-enterprise-landing-zone/infra/README.md) for prerequisites and fresh owner-generated plans.

The architecture root starts with its own local state; never copy dev or seed state into it. Legacy source, seed/dev state, backups and old caches were moved intact into the ignored root `.private/recovery/` area, outside the public case. See [ADR 0016](../../gcp-enterprise-landing-zone/docs/decisions/0016-private-legacy-recovery.md). This filesystem move did not migrate a backend or retire seed resources. Do not run legacy bootstrap. Preserve workload state after destroy, together with independent protected backups. Never run Terraform from recovery directories or reuse historical plans. The active root now uses local state throughout its lifecycle and creates no state bucket; see [ADR 0018](../../gcp-enterprise-landing-zone/docs/decisions/0018-local-state-only.md).

Current provider pins are `google` and `google-beta` 8.5.0 in the active architecture root, with beta used for the display-enabled template. Legacy seed/bootstrap keep their own locks; old records of five identical locks are historical, not a current invariant.

## Commands from the repository root

The owner executes all plans/applies and mock plan suites. Static checks:

```sh
terraform version
terraform -chdir=gcp-enterprise-landing-zone/infra/vm-web-platform validate
terraform -chdir=gcp-enterprise-landing-zone/infra fmt -check -recursive
python3 -m unittest discover -s gcp-enterprise-landing-zone/tests -v
```

A fresh checkout needs the pinned CLI and provider initialization before validation. See the [test index](../../gcp-enterprise-landing-zone/tests/README.md); no mock suite establishes runtime or cleanup guarantees.

## Current evidence and cost boundary

The [evidence register](../../gcp-enterprise-landing-zone/docs/single-project-validation.md) records the historical dev trial's two plan reviews, direct initial VM/LB health observations, owner-reported page access/deployments and final removal of 23 resources. Owner-reported absence of policy-labelled snapshots is not proof of a full residual inventory. The owner subsequently confirmed these dev tests, including residual checks, snapshot creation/restore, telemetry, scaling and failover; no additional artifacts were attached. Production has not been deployed or validated.

Use one BRL 300 cumulative portfolio budget, without mandatory detailed per-case estimates. Reconcile delayed charges and retained resources. Monitoring API remains enabled by design; seed and any retained telemetry are outside workload destruction. The owner-operated one-hour session includes cleanup, with teardown starting by minute 40. No timed compliance or automatic watchdog guarantee is claimed.

Seed review remains due by 2026-11-02. Workload cleanup does not retire seed privileges. These documentation changes authorize no cloud action.

## Restructure validation — 2026-10-03

- Owner confirmed the single-repository layout and reported preserving an external backup before this work. External backup encryption and restoration were not independently tested.
- The seed state matches the pre-move toolchain recovery copy byte-for-byte; a new mode-0600 local recovery copy was also preserved. At that migration, only seed had applied state; the original root path was absent.
- All five Terraform directories passed validation, all 17 mocked Terraform plan tests passed, and all 19 Python controller unit/mock tests passed. The original external test-directory commands failed; the corrected root-local test layout passed without weakening assertions.
- Formatting and local links passed; all five provider lock files match. A limited publication-candidate check found no known private cloud IDs, private state/input/plan artifacts, or common credential patterns. This is not a comprehensive security scan.
- Reviewed human ADC identity and management quota project were verified before fresh read-only cloud plans. Seed returned no changes; bootstrap returned 36 additions and zero changes/removals. Neither plan emitted diagnostics, and the seed state was not rewritten.
- The new bootstrap plan matches the previously reviewed plan's inputs, configuration, planned values, and resource actions. This was a point-in-time comparison. All bootstrap plans are now historical and must not be executed. Raw plans and logs remain under the ignored root `.private/` directory.
- No cloud apply, destroy, access disablement, backend migration, commit, push, GitHub rename, or new repository was performed. Temporary bootstrap access was enabled at that observation. Its retirement remains a separate owner-reviewed seed operation, not part of workload destroy.


## Publication

The profile draft links to case folders in the existing repository. Publication of the updated catalog/profile through the existing Git workflow remains pending; editing local Markdown does not update GitHub.
