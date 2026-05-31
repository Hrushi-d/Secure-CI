# SecureCI — Quick Start

Get a signed, scanned, SBOM-attested image in GHCR in **3 steps**.

## Prereqs

- A GitHub repo with a `Dockerfile`
- Nothing else. No accounts. No secrets. No infrastructure.

## 1. Add this file to your repo

`.github/workflows/ci.yml`:

```yaml
name: ci
on:
  push: { branches: [main] }
  pull_request:

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

## 2. Push

```bash
git add .github/workflows/ci.yml
git commit -m "Add SecureCI"
git push
```

## 3. Watch it run

GitHub → **Actions** tab. 8 gates run in order: secrets → SAST → SCA → build → image
scan → SBOM → sign → push.

## What you get

| Where | What |
| --- | --- |
| GHCR (`ghcr.io/Hrushi-d/<repo>`) | Signed image, tagged `:<sha>` and `:latest` |
| Repo → Security tab | SARIF findings from trivy |
| Actions run → Artifacts | CycloneDX SBOM (`sbom.cdx.json`) |
| Sigstore (Rekor) | Public signature + SBOM attestation |

## Verify any pulled image

```bash
cosign verify ghcr.io/Hrushi-d/<repo>:latest \
  --certificate-identity-regexp "https://github.com/Hrushi-d/.*" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

`Verification PASSED` → the image was provably built by your GitHub Actions, from
your repo, on your commit.

---

## 🖥️ Catch issues before the PR — run the scans locally

Same gates as CI, run on your laptop in seconds. No CI round-trip, no failed-build
emails.

```bash
# Install once (macOS)
brew install gitleaks semgrep trivy

# Scan any folder with a Dockerfile
./scripts/local-scan.sh path/to/app
```

Runs gates 1–5 (gitleaks → semgrep → trivy fs → docker build → trivy image) and
exits non-zero on the first failure. Reports land in `<app>/.secureci-reports/`.

> Pass locally → pass in CI. See [README](README.md#try-it-on-your-laptop-no-ci-required) for Linux install + details.

---

Full details: [README.md](README.md) · Why this exists: [docs/PROBLEM.md](docs/PROBLEM.md) · Verifying images: [docs/verifying-signed-images.md](docs/verifying-signed-images.md)
