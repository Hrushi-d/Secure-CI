# DevSecOps 101 — tools, what they do, and free alternatives

A no-jargon guide to the security categories every modern pipeline should have, the
commercial tools you've heard of, and the free OSS tools that do the same job
(most of them are what SecureCI uses under the hood).

---

## What is DevSecOps?

DevSecOps = **shifting security left**: putting automated security checks
*inside* the developer's normal commit → build → deploy loop, instead of
bolting them on at the end (or never).

Concretely it means:

- **Every push** runs scans.
- **Every image** is signed and has an SBOM.
- **Every finding** lands in the developer's existing tools (PR comments, Security
tab) — not a separate dashboard nobody checks.

The goal isn't perfect security — it's **catching the obvious 95% automatically** so
humans can focus on the hard 5%.

---

## The 8 categories of pipeline security

| # | Category | What it catches | When it runs |
| - | --- | --- | --- |
| 1 | **Secrets scanning** | AWS keys, tokens, passwords in git history | Pre-commit + CI |
| 2 | **SAST** (Static Application Security Testing) | Insecure code patterns: SQLi, XSS, hardcoded creds | CI |
| 3 | **SCA** (Software Composition Analysis) | Vulnerable third-party dependencies (npm, Maven, pip) | CI |
| 4 | **IaC scanning** | Misconfigured Terraform, Kubernetes, Dockerfile | CI |
| 5 | **Container image scanning** | CVEs in OS packages + libs inside the built image | CI, post-build |
| 6 | **SBOM generation** | A machine-readable ingredient list of every binary | CI, post-build |
| 7 | **Image signing & provenance** | Cryptographic proof of *who built what, from where* | CI, post-build |
| 8 | **Admission / runtime policy** | Refuse to deploy/run anything that fails the above | CD / cluster |

Categories 1–7 are CI-side. Category 8 is CD-side (out of SecureCI's scope, but it
pairs naturally — see [README](../README.md#where-it-fits-in-your-cd-pipeline)).

---

## Tools per category — commercial vs free

| Category | Common commercial tool | Free / OSS equivalent | Cost difference |
| --- | --- | --- | --- |
| Secrets | **GitGuardian** | **gitleaks**, trufflehog | $0 vs $25+/dev/mo |
| SAST | **SonarQube Developer Edition**, **Veracode**, **Checkmarx** | **semgrep**, CodeQL (free for public repos) | $0 vs €150+/dev |
| SCA | **Snyk**, **Black Duck**, **JFrog Xray** | **trivy**, **OWASP Dependency-Check**, **OSV-Scanner** | $0 vs $25+/dev |
| IaC | **Snyk IaC**, **Bridgecrew** (Prisma) | **trivy** (config), **checkov**, **tfsec** | $0 vs paid tier |
| Container scan | **Aqua**, **Sysdig Secure**, **Snyk Container** | **trivy** (image), **grype** | $0 vs enterprise license |
| SBOM | (most commercial tools generate one) | **syft** (CycloneDX/SPDX), trivy SBOM | $0 vs bundled-in-paid |
| Signing | (commercial often skips this) | **cosign** keyless (Sigstore) | $0 — no commercial equiv at this price |
| Registry | **JFrog Artifactory**, **Harbor** (self-hosted) | **GHCR** (free for public), **Docker Hub** (limited) | $0 vs thousands/year |
| Admission | **Aqua Enforcer**, **Sysdig Admission** | **Kyverno**, **Sigstore policy-controller**, **OPA Gatekeeper** | $0 vs enterprise license |

> 💡 **The free stack is not inferior** — it's what the largest OSS projects
(Kubernetes, Helm, distroless, Sigstore itself) use in production. Commercial tools
often *bundle* these same engines and add a dashboard on top.

---

## What SecureCI picks (and why)

Out of the dozens of free OSS options, SecureCI picks **one opinionated tool per
category** so you don't have to:

| Gate | Tool | Why this one |
| --- | --- | --- |
| Secrets | **gitleaks** | De-facto OSS standard, very fast, low false-positive rate |
| SAST | **semgrep** | Largest community rule set, OWASP/CWE coverage, multi-language |
| SCA + IaC | **trivy fs** | One scanner for deps + Dockerfile + K8s + Terraform — less to learn |
| Image scan | **trivy image** | Same engine as #3 — no second tool |
| SBOM | **syft** (CycloneDX) | Anchore's scanner; CycloneDX is the OWASP-backed format |
| Signing | **cosign keyless** | Sigstore — recommended by U.S. Executive Order 14028 |
| Registry | **GHCR** | Free, integrated with GitHub identity, native OIDC |

**Want to swap one out?** The workflow is plain GitHub Actions YAML — see [README →
Extending it](../README.md#extending-it--adding-or-swapping-security-tools).

---

## "Do I need all 8?" — a maturity ladder

You don't have to flip everything on day one. A reasonable ramp:

1. **Week 1** — Secrets + SCA + Image scan. *(Catches 80% of real incidents.)*
2. **Week 2** — Add SAST + IaC. *(Catches the rest of the easy code-level bugs.)*
3. **Week 3** — Add SBOM + signing. *(You're now ahead of most enterprises.)*
4. **Month 2** — Add admission policy in your cluster. *(Now you're enforcing.)*

SecureCI gives you steps 1–3 in one workflow call. Step 4 is your CD tool's job.

---

## Further reading

- [OWASP DevSecOps Guideline](https://owasp.org/www-project-devsecops-guideline/)
- [Sigstore docs](https://docs.sigstore.dev/) — what cosign + Rekor + Fulcio actually do
- [SLSA framework](https://slsa.dev/) — supply-chain integrity levels
- [CycloneDX](https://cyclonedx.org/) — the SBOM format SecureCI emits
- [U.S. Executive Order 14028](https://www.cisa.gov/executive-order-improving-nations-cybersecurity) — why SBOMs + signing now matter for federal procurement
- [README](../README.md) · [QUICKSTART](../QUICKSTART.md) · [PROBLEM](PROBLEM.md) · [verifying-signed-images](verifying-signed-images.md)
