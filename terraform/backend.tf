terraform {
  # Remote state in Azure Blob Storage (Phase 6).
  #
  # Auth is via the storage account access key, supplied out-of-band as the
  # ARM_ACCESS_KEY environment variable (locally and as a GitHub Actions secret) —
  # never committed. Keyless auth (use_oidc / use_azuread_auth) is not used: the
  # subscription grants only Contributor, which cannot assign the
  # "Storage Blob Data Contributor" role those methods require.
  #
  # The backend storage (RG f5-sales-demo-tfstate, account f5salesdemotfstate,
  # container tfstate) is bootstrapped once via the Azure CLI — see
  # scripts/bootstrap-azure-state.sh.
  backend "azurerm" {
    resource_group_name  = "f5-sales-demo-tfstate"
    storage_account_name = "f5salesdemotfstate"
    container_name       = "tfstate"
    key                  = "dns.tfstate"
  }
}
