terraform {
  # Azure Blob Storage remote state (Phase 6), configured as a PARTIAL backend:
  # no environment-specific values are hardcoded here. Supply them at init time.
  #
  #   CI:    terraform init -backend-config="resource_group_name=$RG" \
  #                         -backend-config="storage_account_name=$SA" \
  #                         -backend-config="container_name=$CONTAINER" \
  #                         -backend-config="key=$KEY"
  #          (values from GitHub Actions repository variables; see .github/workflows/terraform.yml)
  #   Local: terraform init -backend-config=backend.hcl   (copy backend.hcl.example; gitignored)
  #
  # Auth is the storage account access key via the ARM_ACCESS_KEY environment
  # variable (never committed). Keyless auth (use_oidc / use_azuread_auth) is not
  # used: our Contributor-only RBAC cannot assign the "Storage Blob Data
  # Contributor" role those methods require. Bootstrap: scripts/bootstrap-azure-state.sh.
  backend "azurerm" {}
}

# UAT (1784945009): live check that authenticated verification runs on the runner.
