variable "domain" {
  description = "Zone FQDN (also the resource name). The account must own this domain."
  type        = string
}

variable "namespace" {
  description = "F5 XC namespace (must be 'system' for DNS objects)."
  type        = string
  default     = "system"
}

variable "labels" {
  description = "Labels applied to the DNS zone."
  type        = map(string)
  default     = {}
}

variable "a_records" {
  description = "A records for the zone: map of record name (\"\" = apex) to list of IPv4 addresses."
  type        = map(list(string))
  default     = {}
}

variable "record_ttl" {
  description = "TTL for the demo records (F5 XC requires >= 60)."
  type        = number
  default     = 300
}
