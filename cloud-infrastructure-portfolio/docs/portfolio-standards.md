# Portfolio Standards

## Positioning and naming

Use **Cloud Infrastructure Engineering | GCP & AWS** as the professional headline. Treat it as a focus statement, not a claim of employment, certification, or verified experience.

Use lowercase, hyphen-separated English case folder names. Prefer `<platform>-<infrastructure-topic>` for a platform-specific case and `cloud-<infrastructure-topic>` for a cross-cloud case. The case folders below belong to this single repository; planned folders are not completed projects:

| Case | Case folder name |
| --- | --- |
| GCP Enterprise Landing Zone / Cloud Foundation | `gcp-enterprise-landing-zone` |
| Terraform Enterprise Infrastructure | `terraform-enterprise-infrastructure` |
| Cloud Security Architecture | `cloud-security-architecture` |
| Cloud FinOps Optimization | `cloud-finops-lab` |
| Workload Migration | `workload-migration-case` |

Keep all case folders in `Joads0n/cloud-infrastructure-portfolio`. Shared planning and standards live under `cloud-infrastructure-portfolio/`; case implementation and evidence live in peer case folders. Add a case only for a distinct problem and deliverable. The existing profile repository remains `Joads0n/Joads0n`; profile updates are reviewed separately from this catalog. Do not create separate repositories or nested Git metadata for cases.

## Documentation and evidence

Start each case README with the business problem, scope, current delivery status, and links to available evidence. A recruiter should understand the focus in 30–60 seconds; an engineer should be able to follow requirements through decisions and validation.

Use the [case README template](templates/case-readme.md) as a starting point. Include only applicable sections. Clearly distinguish proposed designs, implemented configuration, executed validation, and measured outcomes. Label synthetic costs and metrics as fictional assumptions; never describe them as measured results.

Record material architecture decisions under `docs/decisions/NNNN-short-title.md` using the [ADR template](templates/adr.md). Start with `0001`. Explain alternatives and consequences. No architecture ADR is needed merely to adopt these documentation conventions.

Use English for repository documents, filenames, commits, issues, and pull requests. All scenarios must be invented independently of employer or customer artifacts. Do not sanitize or adapt real internal material for publication.

## Changes and review

### Terraform module selection

Use direct Google provider resources and local modules only when they provide a clear organizational or reuse benefit. There is no preference or requirement for Google-maintained remote modules. If a remote module is justified later, review and pin its version explicitly; provider locks do not lock module versions. Preserve unique resource ownership, pinned providers, least privilege, and protected state. Review migrations separately for applied roots.

The owner executes all Terraform plans and applies, including destruction. The assistant may edit, format, statically validate, and review sanitized results. Do not run mock suites containing `command = plan` without renewed direction.

Use short-lived branches named `<type>/<short-description>`, such as `docs/profile-foundation` or `feat/network-baseline`. Use concise imperative commit subjects in the form `<type>: <change>`; suggested types are `docs`, `feat`, `fix`, `ci`, and `chore`.

Keep each change focused on one reviewable outcome. Describe its requirement, evidence, risks, and unfinished items in the issue or pull request. Use the repository's [issue template](../../.github/ISSUE_TEMPLATE/engineering-task.md) and [pull request template](../../.github/pull_request_template.md). Check only validations actually performed.

Suggested labels, to create when a GitHub repository is available:

| Label | Purpose |
| --- | --- |
| `documentation` | Documentation and evidence changes |
| `architecture` | Requirements, design, and ADR work |
| `infrastructure` | Infrastructure configuration and implementation |
| `security` | Access controls and repository or cloud safety |
| `validation` | Checks, tests, and validation evidence |
| `cost` | Estimates, allocation, and cleanup |
| `blocked` | Work awaiting a specific dependency |

## Repository safety and merge policy

The repository-root `.gitignore` excludes common local credentials, Terraform state, variable inputs, and plan files. It is a convenience, not a secret detector: inspect staged files and the staged diff before each commit. Never add credentials, identifying data, or real environment artifacts. Use only fictional placeholders in any committed `.env.example`.

When Terraform is introduced, commit the dependency lock file, pin supported tool versions, and document required inputs using fictional examples. Keep local state and sensitive inputs outside version control. Plans and logs can contain sensitive values and require review before sharing.

Before publishing, review the complete file set and any Git history. If potentially confidential material is found, stop publication and flag it. If a credential is exposed, revoke or rotate it before addressing repository history; deleting the visible file alone is insufficient.

Proposed merge policy for a future GitHub repository: protect the default branch against deletion and force pushes, use pull requests to record changes, and require applicable checks once those checks exist. Require an independent review when a collaborator is available; for a solo portfolio, document self-review. These are desired controls, not a claim that any GitHub settings have been configured. Verify available controls when configuring the remote repository.

Use one cumulative BRL 300 budget record across the portfolio; detailed estimates for every case are not required. Before a cloud session, review expected billable services, duration, remaining headroom, delayed charges, a conservative session allowance where needed, and teardown/residual costs. Document-only and local-only cases need no cloud estimate. This operational ceiling is not a provider-enforced spending cap. Use short-lived authentication when automation becomes necessary.
