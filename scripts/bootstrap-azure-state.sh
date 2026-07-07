#!/usr/bin/env bash
# Bootstrap the Azure Blob Storage backend for Terraform remote state (Phase 6).
#
# One-time, out-of-band setup: the state backend cannot store its own bootstrap
# (chicken-and-egg). Run once with an authenticated Azure CLI session
# (`az login`) that has Contributor on the subscription.
#
# Auth model: the azurerm backend authenticates with the storage account access
# key (exported as ARM_ACCESS_KEY), NOT keyless OIDC/Azure AD — the subscription
# grants only Contributor, which cannot assign the "Storage Blob Data
# Contributor" role that keyless data-plane access requires. Contributor CAN read
# the account key, so the key path needs no role assignment.
set -euo pipefail

SUBSCRIPTION="${AZURE_SUBSCRIPTION_ID:-00000000-0000-0000-0000-000000000000}"
RESOURCE_GROUP="f5-sales-demo-tfstate"
STORAGE_ACCOUNT="f5salesdemotfstate"
CONTAINER="tfstate"
LOCATION="eastus2"

az account set --subscription "$SUBSCRIPTION"

az group create --name "$RESOURCE_GROUP" --location "$LOCATION" \
  --tags managed_by=terraform use_case=dns purpose=tfstate

az storage account create --name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" --sku Standard_LRS --kind StorageV2 \
  --min-tls-version TLS1_2 --allow-blob-public-access false \
  --tags managed_by=terraform use_case=dns purpose=tfstate

# State safety: keep prior versions and allow recovery of deleted state blobs.
az storage account blob-service-properties update \
  --account-name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" \
  --enable-versioning true \
  --enable-delete-retention true --delete-retention-days 7 \
  --enable-container-delete-retention true --container-delete-retention-days 7

KEY="$(az storage account keys list \
  --account-name "$STORAGE_ACCOUNT" --resource-group "$RESOURCE_GROUP" \
  --query '[0].value' -o tsv)"

az storage container create --name "$CONTAINER" \
  --account-name "$STORAGE_ACCOUNT" --auth-mode key --account-key "$KEY"

cat <<EOF

Bootstrap complete.

Export for local Terraform runs:
  export ARM_ACCESS_KEY="<key>"   # az storage account keys list ... --query '[0].value' -o tsv

Set as GitHub Actions secrets on f5-sales-demo/dns (for CI):
  gh secret set ARM_ACCESS_KEY -R f5-sales-demo/dns
  gh secret set XCSH_API_URL   -R f5-sales-demo/dns
  gh secret set XCSH_API_TOKEN -R f5-sales-demo/dns
EOF
