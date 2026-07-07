terraform {
  required_version = ">= 1.5"

  required_providers {
    xcsh = {
      source = "f5-sales-demo/xcsh"
      # First registry release that ships the DNS resources (xcsh_dns_zone,
      # dns_lb_*, geo_location_set). Earlier releases lack them. Locally the
      # provider is consumed via dev_overrides, which ignores this constraint.
      version = ">= 3.61.15"
    }
  }
}
