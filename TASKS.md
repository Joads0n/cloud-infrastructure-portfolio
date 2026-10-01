# Portfolio Roadmap

## Phase 0 — Professional GitHub Foundation

- [x] Confirm the GitHub username and whether the profile repository (`<username>/<username>`) already exists.
- [x] Define the professional headline, short bio, contact links, and optional certifications for the profile README.
- [x] Define the portfolio naming convention and repository taxonomy.
- [x] Create the profile README with a recruiter-friendly overview and curated project links.
- [x] Establish reusable documentation, ADR, issue, pull request, commit, branch, and label standards.
- [x] Configure repository safety basics: `.gitignore`, secret-aware practices, and branch protection recommendations.

Local artifacts are available in [portfolio standards](docs/portfolio-standards.md) and the [profile README source](docs/profile-readme-draft.md). The headline is **Cloud Infrastructure Engineering | GCP & AWS**. The owner confirmed the GitHub username `Joads0n`, creation of `Joads0n/cloud-infrastructure-portfolio`, and the existing profile repository `Joads0n/Joads0n`, and reported completing the review. The profile README links to the portfolio and retains the name, email, and LinkedIn link from the existing public profile. Certifications are omitted because none have been supplied; add curated case links only when those cases exist.

Git is initialized in this workspace on `main`, with `origin` set to `git@github.com:Joads0n/cloud-infrastructure-portfolio.git`. SSH read access to both repositories was verified on 2026-10-01. The portfolio remote was empty, and the existing profile README was inspected before preparing its update. The completed tasks above describe the prepared artifacts; publication is tracked separately below.

- [ ] Publish the portfolio foundation to `Joads0n/cloud-infrastructure-portfolio`.
- [ ] Publish the revised profile README to `Joads0n/Joads0n`.

Label creation and branch protection configuration remain pending; only their recommended standards have been documented.

## Phase 1 — GCP Enterprise Landing Zone / Cloud Foundation

- [ ] Define a fictional business scenario, constraints, and non-functional requirements.
- [ ] Produce the architecture overview and key ADRs before Terraform implementation.
- [ ] Define resource hierarchy, project model, networking, IAM, logging, policies, and cost-allocation strategy.
- [ ] Implement only the IaC needed to demonstrate the approved architecture.
- [ ] Validate formatting, Terraform configuration, security posture, and documentation consistency.

## Future cases

- [ ] Terraform Enterprise Infrastructure
- [ ] Cloud Security Architecture
- [ ] Cloud FinOps Optimization Case
- [ ] Workload Migration Case
- [ ] Hybrid Cloud Networking
- [ ] Cloud Governance Framework
- [ ] Disaster Recovery Architecture
