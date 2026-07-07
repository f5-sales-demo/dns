variable "namespace" {
  description = "F5 XC namespace for DNS objects. DNS objects MUST live in 'system' (the API rejects other namespaces)."
  type        = string
  default     = "system"

  validation {
    condition     = var.namespace == "system"
    error_message = "F5 XC DNS objects must be created in the 'system' namespace."
  }
}

variable "domain" {
  description = "DNS zone FQDN (required; supplied via TF_VAR_domain / a GitHub Actions variable / tfvars — not hardcoded). Our delegated, prerelease test domain in the production tenant."
  type        = string
}

variable "labels" {
  description = "Labels applied to managed DNS objects."
  type        = map(string)
  default = {
    managed_by = "terraform"
    use_case   = "dns"
  }
}

variable "a_records" {
  description = "A records for the zone: record name (\"\" = apex) to list of IPv4 addresses. Mirrors manifests/f5-sales-demo-com.json (RFC 5737 documentation addresses)."
  type        = map(list(string))
  default = {
    www = ["203.0.113.10"]
    app = ["203.0.113.20"]
    api = ["203.0.113.30"]
  }
}
