output "dns_zone_name" {
  description = "Name of the managed DNS zone."
  value       = module.dns_zone.name
}

output "dns_zone_id" {
  description = "F5 XC identifier of the managed DNS zone."
  value       = module.dns_zone.id
}
