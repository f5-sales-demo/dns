# DNS use-case Terraform reference plan

Terraform plan that provisions the F5 Distributed Cloud DNS demo using the
[`terraform-provider-xcsh`](https://github.com/f5-sales-demo/terraform-provider-xcsh)
provider. It targets the production tenant against a dedicated, delegated, prerelease test
domain, with remote state in Azure Blob Storage.

## Layout

| Path | Purpose |
| --- | --- |
| `versions.tf` | Terraform + provider version pins |
| `providers.tf` | `xcsh` provider (auth from environment) |
| `backend.tf` | Azure Blob Storage remote state (`azurerm`, access-key auth) |
| `variables.tf` / `terraform.tfvars.example` | Inputs (namespace, domain, labels, records) |
| `main.tf` / `outputs.tf` | Module wiring |
| `modules/dns-zone/` | Authoritative primary DNS zone with records |

`modules/dns-lb/` (DNS Load Balancer: health check + pool + load balancer, plus `lb_record`
entries in the zone) is a follow-up once the `lb_record` wire format is resolved.

## Prerequisites

- Terraform >= 1.5
- The `xcsh` provider. Locally it is consumed via `dev_overrides` (below); CI uses the released
  version pinned in `versions.tf` from the registry.
- Azure remote-state backend bootstrapped once — see [`scripts/bootstrap-azure-state.sh`](../scripts/bootstrap-azure-state.sh).

### Local provider (dev_overrides)

Build the provider and point Terraform at the binary — each rebuild is picked up with no reinstall:

```sh
make -C ../../terraform-provider-xcsh build   # adjust path to your checkout

cat > ~/.terraformrc <<'RC'
provider_installation {
  dev_overrides {
    "registry.terraform.io/f5-sales-demo/xcsh" = "/absolute/path/to/terraform-provider-xcsh"
  }
  direct {}
}
RC
```

Under `dev_overrides` the provider is not downloaded, but `terraform init` is still required
once to configure the `azurerm` backend.

### Configuration (nothing environment-specific is hardcoded)

No environment values live in the `.tf` files. Supply them at run time:

| Value | CI source | Local source |
| --- | --- | --- |
| Backend coords (`resource_group_name`, `storage_account_name`, `container_name`, `key`) | GitHub **variables** `TFSTATE_*`, passed via `-backend-config` | `backend.hcl` (copy `backend.hcl.example`; gitignored) |
| `domain`, `namespace` | GitHub **variables** `DNS_DOMAIN` / `DNS_NAMESPACE`, as `TF_VAR_*` | `terraform.tfvars` (copy the example; gitignored) or `TF_VAR_*` |
| `ARM_ACCESS_KEY` (state auth) | GitHub **secret** | `export ARM_ACCESS_KEY=...` |
| `XCSH_API_URL`, `XCSH_API_TOKEN` (provider auth) | GitHub **secrets** | `export XCSH_API_URL=... XCSH_API_TOKEN=...` |

```sh
export XCSH_API_URL="https://<tenant>.console.ves.volterra.io"
export XCSH_API_TOKEN="<api-token>"           # provider auth (header: APIToken <token>)
export ARM_ACCESS_KEY="<storage-account-key>" # azurerm backend auth (never committed)
cp backend.hcl.example backend.hcl            # edit if your coords differ
cp terraform.tfvars.example terraform.tfvars  # sets domain, namespace, records
```

## Usage

```sh
terraform init -backend-config=backend.hcl   # partial backend: coords from backend.hcl
terraform fmt -check
terraform validate
terraform plan
terraform apply
terraform destroy
```

> DNS objects must be created in the `system` namespace (the API rejects others).
> The domain is delegated to F5 XC, so managed records resolve on the public internet.
