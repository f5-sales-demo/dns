terraform {
  required_version = ">= 1.5"

  required_providers {
    xcsh = {
      source = "f5-sales-demo/xcsh"
      # >= 3.72.18: release where the provider stops surfacing the F5XC
      # system-managed "x-ves-io-managed" rr_set_group (auto-created when
      # allow_http_lb_managed_records = true) as Terraform state. Earlier
      # releases planned to delete that group, and apply failed 403 FORBIDDEN
      # (the group is platform-owned). See terraform-provider-xcsh #1167.
      # (Floor also covers >= 3.62.0: namespace defaults to "system", spec-driven.)
      # Locally the provider is consumed via dev_overrides, which ignores this.
      version = ">= 3.72.18"
    }
  }
}
