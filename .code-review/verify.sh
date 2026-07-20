#!/usr/bin/env bash
#
# Authenticated verification for the governed Claude PR reviewer.
#
# The docs-control reusable reviewer (.github/workflows/claude-review.yml) runs
# `bash .code-review/verify.sh` when its caller passes no verify_cmd. It executes
# on the self-hosted, VPN-connected runner as the logged-in operator, so it MAY
# reach internal APIs and use the host's real az/gh/terraform sessions.
#
# For dns the meaningful, safe check is that the Terraform configuration is
# well-formatted, initializes, and validates. This is deterministic, re-runnable,
# and needs NO Azure credentials or remote state.
#
# Why not a plain `terraform init -backend=false && terraform validate`: this repo
# uses a PARTIAL azurerm backend (`backend "azurerm" {}` — coords injected at CI
# init time). On Terraform 1.6+, `terraform validate` resolves the backend block
# and fails on the unset required arguments, and a real azurerm `init` would need
# ARM_ACCESS_KEY + the state coords. So for verification we override the backend to
# `local` for the duration of the run: no credentials, no state blob, nothing
# committed. The override and all init artifacts are removed on exit.
#
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tf_dir="${script_dir}/../terraform"
cd "${tf_dir}"

# Format check on the pristine tree, before writing the temporary override.
echo "==> terraform fmt -check -recursive"
terraform fmt -check -recursive

override="backend_override.tf"
cleanup() {
  rm -f "${tf_dir}/${override}"
  rm -rf "${tf_dir}/.terraform" "${tf_dir}/.terraform.lock.hcl"
}
trap cleanup EXIT

cat >"${override}" <<'HCL'
# TEMPORARY — written by .code-review/verify.sh for credential-free validation.
# Overrides the partial azurerm backend with a local backend so `init`/`validate`
# need no Azure state or credentials. Removed on exit; never committed.
terraform {
  backend "local" {}
}
HCL

echo "==> terraform init (local backend, no credentials)"
terraform init -input=false

echo "==> terraform validate"
terraform validate -no-color

echo "==> verify.sh OK"
