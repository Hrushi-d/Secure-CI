# The problem SecureCI solves

## The state of DevSecOps for everyone who isn't an enterprise

Big companies have it figured out. They have:

- A platform team that owns CI/CD.
- Licenses for SonarQube, GitGuardian, Snyk, Veracode, Artifactory, Neuvector.
- A security team that wires those tools into every pipeline.
- An auditor who shows up once a year and signs off.

**Everybody else has none of that.**

If you're a solo developer, a side-project hacker, a 5-person startup, an OSS
maintainer, or a student building a portfolio — you face the same supply-chain
threats as a Fortune 500, but with **zero budget and zero specialist time**.

The result is depressingly consistent:

- Secrets get committed to public repos. *(Every year. Millions of times.)*
- Vulnerable npm/Maven packages ship to production.
- Docker images are built `FROM ubuntu:latest` with no scanning.
- Images are pushed to Docker Hub **unsigned** — anyone who controls the tag
  can swap the binary and nobody would know.
- No SBOM exists, so when the next Log4Shell hits, you can't even tell whether
  you're affected.

---

## Why the obvious answers don't work

### "Just use commercial tools."
- SonarQube Developer Edition: ~€150 + per developer.
- Snyk Team: $25 / dev / month minimum.
- GitGuardian: paid above 25 contributors.
- JFrog Artifactory: thousands per year for the cheapest tier.

Side projects and pre-seed startups simply won't pay this. So they ship
**nothing** instead.

### "Just wire up the OSS tools yourself."
You can. But it's a real project:

- Pick the right tool in each category (and there are 5+ options each).
- Learn each tool's CLI, config format, and failure modes.
- Wire them into GitHub Actions correctly.
- Get the permissions right for OIDC, GHCR, SARIF upload.
- Figure out cosign keyless signing — which most developers have never heard of.
- Maintain it as tools change.

A weekend or two of work, **per project**. Most developers stop after step 1.

### "Just trust the base image."
This is the most common answer and the most dangerous. `FROM node:20-alpine`
gives you no guarantees about:

- whether the *next* `:20-alpine` tag was tampered with,
- whether *your* layered code introduced a CVE,
- whether *your* image is the one your users actually pulled.

---

## What SecureCI does about it

It collapses "a weekend of work, per project" into **10 lines of YAML, once.**

```yaml
jobs:
  secureci:
    uses: Hrushi-d/Secure-CI/.github/workflows/secureci.yml@v1
    with:
      image-name: ghcr.io/${{ github.repository }}
    permissions:
      contents: read
      packages: write
      id-token: write
      security-events: write
```

Behind that one line you get the same 8-stage pipeline a platform team would
build for you, using the same primitives the largest OSS projects in the world
already use:

| Stage | Tool | Why this tool |
| --- | --- | --- |
| Secrets | **gitleaks** | De-facto OSS standard, fast, low false-positive rate. |
| SAST | **semgrep** | Largest community rule set, OWASP/CWE coverage. |
| SCA + IaC | **trivy fs** | One scanner for deps, Dockerfiles, K8s, Terraform. |
| Image scan | **trivy image** | Same engine, no second tool to learn. |
| SBOM | **syft** (CycloneDX) | Anchore's scanner; CycloneDX is the OWASP-backed format. |
| Signing | **cosign keyless** | Sigstore — recommended by the U.S. Executive Order 14028 on supply-chain security. |
| Registry | **GHCR** | Free, integrated with GitHub identity, no separate account. |

---

## The deeper problem: supply-chain trust

The biggest supply-chain attacks of the last few years
(SolarWinds, Codecov, `event-stream`, the xz backdoor) all share a pattern:

> **A legitimate publisher's release pipeline was compromised. Users had no way
> to tell.**

Cosign keyless signing fixes this for you, for free. Every image SecureCI
publishes carries a Sigstore signature that cryptographically proves:

- *This image was built by GitHub Actions.*
- *From this repository.*
- *On this commit.*
- *By this workflow.*

Your users can verify it in one command:

```bash
cosign verify ghcr.io/Hrushi-d/<repo>:<tag> \
  --certificate-identity-regexp "https://github.com/Hrushi-d/.*" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

That's a property even most enterprise pipelines don't have yet. Your side
project can.

---

## Where this is NOT the right answer

To be honest about the limits:

- **You need a real security program at scale.** Once you have customers,
  auditors, and SLAs, you need humans owning it — not a YAML file.
- **It doesn't replace code review or threat modelling.** It catches the
  obvious classes of issues, not architectural ones.
- **It assumes GitHub.** If you're on GitLab / Bitbucket / Azure DevOps, the
  pattern is portable but you'll need to adapt the workflow to your CI system.
- **It won't make insecure code secure.** It will tell you, fast and
  consistently, when your code is insecure. The fix is still yours.

---

## TL;DR

SecureCI gives every developer the supply-chain security posture that
used to require a platform team and a six-figure tooling budget — for **$0,
in 10 lines of YAML, on infrastructure you already use.**

That's the problem it solves.
