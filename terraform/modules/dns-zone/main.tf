# Manages an F5 XC authoritative primary DNS zone with A records.
#
# DNS objects must be created in the 'system' namespace, the zone name must be an
# FQDN the account owns, and record TTLs must be >= 60.
resource "xcsh_dns_zone" "this" {
  name      = var.domain
  namespace = var.namespace
  labels    = var.labels

  primary {
    default_soa_parameters {}

    rr_set_group {
      metadata {
        name = "demo-records"
      }

      dynamic "rr_set" {
        for_each = var.a_records
        content {
          ttl = var.record_ttl
          a_record {
            name   = rr_set.key
            values = rr_set.value
          }
        }
      }
    }
  }
}
