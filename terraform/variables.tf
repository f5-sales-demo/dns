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
  description = "Static A records for the zone: record name (\"\" = apex) to list of IPv4 addresses. NOTE: www and api are intentionally NOT managed here — they are owned by the webapp-api-protection HTTP load balancer via allow_http_lb_managed_records (F5 XC auto-manages those records to the LB VIP). Keep only records not fronted by an XC load balancer."
  type        = map(list(string))
  default = {
    app = ["203.0.113.20"]
  }
}
