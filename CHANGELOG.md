# Changelog

All notable changes to SecureCI are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] — 2026-05-29

Initial public release.

### Added
- Reusable GitHub Actions workflow `secureci.yml` with 8 gates: gitleaks,
  semgrep, trivy fs, docker build, trivy image, syft SBOM,
  cosign keyless signing, GHCR push.
- Local runner `scripts/local-scan.sh` mirroring CI gates 1–5.
- Java + Node sample apps with multi-stage Dockerfiles.
- Docs: `README`, `QUICKSTART`, `docs/PROBLEM`, `docs/DEVSECOPS-101`,
  `docs/verifying-signed-images`.
- `SECURITY.md` private-disclosure policy.
- Dependabot config for actions, maven, npm, and docker.

[Unreleased]: https://github.com/Hrushi-d/secureci/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Hrushi-d/secureci/releases/tag/v1.0.0
