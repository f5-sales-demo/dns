# Manages an F5 XC authoritative primary DNS zone with A records.
#
# The zone name must be an FQDN the account owns, and record TTLs must be >= 60.
# namespace is omitted: the provider fixes DNS objects to the 'system' namespace
# (from the API spec's namespace constraint), so it defaults correctly.
resource "xcsh_dns_zone" "this" {
  name   = var.domain
  labels = var.labels

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
