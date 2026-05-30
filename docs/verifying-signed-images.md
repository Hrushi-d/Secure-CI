# Verifying a SecureCI image

Every image published by `secureci` is signed with **cosign keyless**
(Sigstore + GitHub OIDC) and ships with a **CycloneDX SBOM attestation**.

## 1. Install cosign

```bash
brew install cosign          # macOS
# or: https://docs.sigstore.dev/cosign/installation

curl -O -L "https://github.com/sigstore/cosign/releases/latest/download/cosign-linux-amd64"      # Linux
sudo install cosign-linux-amd64 /usr/local/bin/cosign
```

## 2. Verify the signature

```bash
cosign verify \
  --certificate-identity-regexp "https://github.com/Hrushi-d/.*" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ghcr.io/Hrushi-d/<repo>:<tag>
```

A valid signature proves the image was built by **your** GitHub Actions
workflow, on **your** repo, on **your** main branch — not by anyone else.

## 3. Verify and inspect the SBOM

```bash
cosign verify-attestation \
  --type cyclonedx \
  --certificate-identity-regexp "https://github.com/Hrushi-d/.*" \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  ghcr.io/Hrushi-d/<repo>:<tag> \
  | jq -r '.payload | @base64d | fromjson | .predicate' > sbom.cdx.json

# List all components in the image
jq -r '.components[] | "\(.name) \(.version)"' sbom.cdx.json
```

## 4. (Optional) Enforce at admission

In Kubernetes, use **Kyverno** or **Sigstore policy-controller** to refuse
any pod whose image isn't signed by your identity. Example policy snippets
live upstream in the Sigstore docs.
