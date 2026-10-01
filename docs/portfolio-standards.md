# Portfolio Standards

## Positioning and naming

Use **Cloud Infrastructure Engineering | GCP & AWS** as the professional headline. Treat it as a focus statement, not a claim of employment, certification, or verified experience.

Use lowercase, hyphen-separated English repository names. Prefer `<platform>-<infrastructure-topic>` for a platform-specific case and `cloud-<infrastructure-topic>` for a cross-cloud case. Examples below are proposed names, not published projects:

| Case | Proposed repository name |
| --- | --- |
| GCP Enterprise Landing Zone / Cloud Foundation | `gcp-enterprise-landing-zone` |
| Terraform Enterprise Infrastructure | `cloud-terraform-infrastructure` |
| Cloud Security Architecture | `cloud-security-architecture` |
| Cloud FinOps Optimization | `cloud-finops-optimization` |
| Workload Migration | `cloud-workload-migration` |
| Hybrid Cloud Networking | `cloud-hybrid-networking` |
| Cloud Governance | `cloud-governance-framework` |
| Disaster Recovery | `cloud-disaster-recovery` |

Keep this planning repository, `Joads0n/cloud-infrastructure-portfolio`, separate from case implementations. Create each case only when there is a distinct problem and deliverable; combine overlapping topics when that produces clearer evidence. The existing profile repository is `Joads0n/Joads0n`; the local [profile draft](profile-readme-draft.md) is intended for its root `README.md` after reviewing any existing content.

## Documentation and evidence

Start each case README with the business problem, scope, current delivery status, and links to available evidence. A recruiter should understand the focus in 30–60 seconds; an engineer should be able to follow requirements through decisions and validation.

Use the [case README template](templates/case-readme.md) as a starting point. Include only applicable sections. Clearly distinguish proposed designs, implemented configuration, executed validation, and measured outcomes. Label synthetic costs and metrics as fictional assumptions; never describe them as measured results.

Record material architecture decisions under `docs/decisions/NNNN-short-title.md` using the [ADR template](templates/adr.md). Start with `0001`. Explain alternatives and consequences. No architecture ADR is needed merely to adopt these documentation conventions.

Use English for repository documents, filenames, commits, issues, and pull requests. All scenarios must be invented independently of employer or customer artifacts. Do not sanitize or adapt real internal material for publication.

## Changes and review

Use short-lived branches named `<type>/<short-description>`, such as `docs/profile-foundation` or `feat/network-baseline`. Use concise imperative commit subjects in the form `<type>: <change>`; suggested types are `docs`, `feat`, `fix`, `ci`, and `chore`.

Keep each change focused on one reviewable outcome. Describe its requirement, evidence, risks, and unfinished items in the issue or pull request. Use the repository's [issue template](../.github/ISSUE_TEMPLATE/engineering-task.md) and [pull request template](../.github/pull_request_template.md). Check only validations actually performed.

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

The root `.gitignore` excludes common local credentials, Terraform state, variable inputs, and plan files. It is a convenience, not a secret detector: inspect staged files and the staged diff before each commit. Never add credentials, identifying data, or real environment artifacts. Use only fictional placeholders in any committed `.env.example`.

When Terraform is introduced, commit the dependency lock file, pin supported tool versions, and document required inputs using fictional examples. Keep local state and sensitive inputs outside version control. Plans and logs can contain sensitive values and require review before sharing.

Before publishing, review the complete file set and any Git history. If potentially confidential material is found, stop publication and flag it. If a credential is exposed, revoke or rotate it before addressing repository history; deleting the visible file alone is insufficient.

Proposed merge policy for a future GitHub repository: protect the default branch against deletion and force pushes, use pull requests to record changes, and require applicable checks once those checks exist. Require an independent review when a collaborator is available; for a solo portfolio, document self-review. These are desired controls, not a claim that any GitHub settings have been configured. Verify available controls when configuring the remote repository.

Before any cloud deployment, document the estimated cost, assumptions, teardown procedure, and resources that could continue charging after a partial cleanup. Use short-lived authentication when automation becomes necessary.
