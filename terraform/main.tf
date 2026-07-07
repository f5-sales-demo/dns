# DNS use-case reference plan.
#
# dns-zone — an authoritative primary zone with A records for the delegated
# f5-sales-demo.com test domain.
#
# A follow-up adds ./modules/dns-lb (DNS Load Balancer: health check + pool +
# load balancer, plus lb_record entries in the zone) once the lb_record wire
# format is resolved.

module "dns_zone" {
  source = "./modules/dns-zone"

  domain    = var.domain
  labels    = var.labels
  a_records = var.a_records
}
