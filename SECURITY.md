# Security Policy

SecureCI is a small OSS project. Reporting is intentionally lightweight.

## Reporting a vulnerability

**For most issues — just open a public GitHub issue.** That's fine and preferred.
Faster triage, public discussion, no friction.

👉 <https://github.com/Hrushi-d/Secure-CI/issues/new>

## When to report privately instead

Only if **all three** are true:

1. The issue is in SecureCI itself (not in your own app or in an upstream tool).
2. It's actively exploitable.
3. Disclosing it publicly before a fix would put existing users at real risk.

Then use GitHub's private vulnerability reporting:
<https://github.com/Hrushi-d/Secure-CI/security/advisories/new>

## Scope

In scope:

- The reusable workflow `.github/workflows/secureci.yml`.
- The local runner `scripts/local-scan.sh`.
- The sample Dockerfiles in `samples/`.

Out of scope (report upstream instead):

- Bugs in third-party actions (gitleaks, semgrep, trivy, syft, cosign, etc.) —
  report to those projects directly.
- Vulnerabilities in **your own** image scanned by SecureCI — that's what the
  pipeline is for; fix the finding in your code.

## Supply-chain guarantees

Every release of SecureCI is signed and SBOM-attested by the same workflow it
ships. Verify any release with:

```bash
cosign verify \
  --certificate-identity-regexp "https://github.com/Hrushi-d/Secure-CI/.*" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ghcr.io/Hrushi-d/Secure-CI:<tag>
```
