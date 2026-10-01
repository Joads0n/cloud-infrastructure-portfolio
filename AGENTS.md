# Portfolio Engineering Guide

## Purpose and positioning

This repository is part of a technical portfolio for **Cloud Infrastructure Engineering**, with emphasis on Google Cloud Platform, AWS, Cloud Security, Networking, Governance, FinOps, Reliability, and Infrastructure as Code. It must not be presented as a Software, Backend, Frontend, or Full Stack Development portfolio.

Every artifact should demonstrate engineering judgement: problem framing, requirements, architecture, decisions, implementation, validation, security, governance, cost awareness, trade-offs, and outcomes.

## Confidentiality is non-negotiable

Never add or derive artifacts from a real employer, customer, or prior professional environment. This includes client or company names, account/project IDs, IPs, domains, workload names, tickets, incidents, console screenshots, costs, diagrams, Terraform, internal documentation, credentials, or secrets.

Use a clearly fictional company, environment, private address ranges, workloads, metrics, costs, and requirements. Stop and flag any potential exposure before proceeding.

## Documentation standards

- Write repository-facing documentation, ADRs, issues, pull requests, commits, and file names in English unless explicitly requested otherwise.
- Write for two audiences: a recruiter who needs a clear overview in 30–60 seconds and an engineer who needs technical depth.
- Prefer evidence-based, precise language. Do not use unsupported claims or promotional language.
- Do not create sections, diagrams, automation, or Terraform solely to make a repository look more complex.
- Add an ADR under `docs/decisions/` for material architecture decisions. Include Context, Decision, Alternatives Considered, Consequences, and Trade-offs.

## Engineering principles

Apply only the controls relevant to the case, while considering:

- Security: least privilege, separation of duties, encryption, secrets management, secure-by-default, segmentation, and logging.
- Reliability: availability, backups, disaster recovery, RTO/RPO, monitoring, and observability.
- Networking: address planning, routing, DNS, NAT, VPN/hybrid connectivity, firewall policies, and segmentation.
- Governance: resource hierarchy, naming, labels, organization policies, IAM governance, and centralized logging.
- FinOps: allocation, budgets, forecasting, rightsizing, lifecycle, and waste reduction.
- IaC: reusable Terraform where justified, state isolation, pinned versions, validation, linting, security scanning, and environment separation.

## Change workflow

1. Inspect the current repository and identify affected files.
2. State assumptions and propose alternatives when a decision is material.
3. Make the smallest change that meets the requirement.
4. Validate the applicable documentation, formatting, checks, and security risks.
5. Report changed files, rationale, validation, open items, and the recommended next step.

## Repository safety

- Never commit credentials, keys, tokens, `.tfstate`, sensitive `.tfvars`, `.env` files, or identifying data.
- Prefer short-lived authentication, GitHub Secrets, and Workload Identity Federation over persistent keys when automation is introduced.
- Evaluate expected cloud cost before provisioning resources, prefer low-cost demonstrations, and document cleanup actions.
