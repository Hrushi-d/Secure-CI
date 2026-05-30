#!/usr/bin/env bash
# secureci — local runner
#
# Runs the SAME security gates locally that the GitHub Actions workflow runs in CI.
# Lets developers validate a service before pushing, with zero infrastructure.
#
# Gates (all 100% OSS, no accounts required):
#
#   # Gate        Tool
#   ——————————————————————————————
#   1  Secrets    gitleaks
#   2  SAST       semgrep
#   3  SCA + IaC  trivy fs
#   4  Container  docker build
#   5  Image scan trivy image
#
# Usage:
#   ./scripts/local-scan.sh <path-to-app> [image-name]
# Example:
#   ./scripts/local-scan.sh samples/java samples-java:local
#
# Requirements (install once):
#   docker, gitleaks, semgrep, trivy
#
#   On macOS:  brew install gitleaks semgrep trivy
#   On Linux:  see https://github.com/gitleaks/gitleaks  https://semgrep.dev
#              https://github.com/aquasecurity/trivy

set -euo pipefail

APP_PATH="${1:-.}"
IMAGE_NAME="${2:-secureci-local:$(date +%s)}"
REPORTS_DIR="${APP_PATH}/.secureci-reports"

mkdir -p "$REPORTS_DIR"

step()  { printf "\n\033[1;36m— %s —\033[0m\n" "$*"; }
ok()    { printf "\033[1;32m✔ %s\033[0m\n" "$*"; }
warn()  { printf "\033[1;33m▲ %s\033[0m\n" "$*"; }
fail()  { printf "\033[1;31m✘ %s\033[0m\n" "$*"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

# — 1. Secrets scan ————————————————————————————————————————————————————————
step "🔑 Secrets scan (gitleaks)"
if have gitleaks; then
  gitleaks detect --source "$APP_PATH" --no-banner \
    --report-path "$REPORTS_DIR/gitleaks.json" --report-format json \
    || fail "Secrets detected — see $REPORTS_DIR/gitleaks.json"
  ok "No secrets detected"
else
  warn "gitleaks not installed — skipping"
fi

# — 2. SAST ————————————————————————————————————————————————————————————————
step "🔍 SAST (semgrep)"
if have semgrep; then
  semgrep scan --config=auto --error \
    --json --output "$REPORTS_DIR/semgrep.json" "$APP_PATH" \
    || fail "SAST findings — see $REPORTS_DIR/semgrep.json"
  ok "No SAST findings"
else
  warn "semgrep not installed — skipping"
fi

# — 3. SCA + IaC ————————————————————————————————————————————————————————————
step "🛡️ SCA + IaC (trivy fs)"
if have trivy; then
  trivy fs --severity HIGH,CRITICAL --exit-code 1 --ignore-unfixed \
    --format json --output "$REPORTS_DIR/trivy-fs.json" "$APP_PATH" \
    || fail "Vulnerable deps / IaC findings — see $REPORTS_DIR/trivy-fs.json"
  ok "No High/Critical SCA or IaC findings"
else
  warn "trivy not installed — skipping"
fi

# — 4. Container build ————————————————————————————————————————————————————
step "🐳 Build container image"
if [[ -f "$APP_PATH/Dockerfile" ]]; then
  docker build -t "$IMAGE_NAME" "$APP_PATH"
  ok "Built $IMAGE_NAME"
else
  warn "No Dockerfile at $APP_PATH/Dockerfile — skipping build & scan"
  exit 0
fi

# — 5. Container scan ————————————————————————————————————————————————————
step "🔵 Container scan (trivy image)"
if have trivy; then
  trivy image --severity HIGH,CRITICAL --exit-code 1 --ignore-unfixed \
    --format json --output "$REPORTS_DIR/trivy-image.json" \
    "$IMAGE_NAME" \
    || fail "High/Critical CVEs in image — see $REPORTS_DIR/trivy-image.json"
  ok "Image clean of High/Critical CVEs"
else
  warn "trivy not installed — skipping"
fi

step "✅ SecureCI local checks passed"
echo "Reports written to: $REPORTS_DIR"
