output "name" {
  description = "Zone name (FQDN)."
  value       = xcsh_dns_zone.this.name
}

output "id" {
  description = "F5 XC identifier of the DNS zone."
  value       = xcsh_dns_zone.this.id
}
