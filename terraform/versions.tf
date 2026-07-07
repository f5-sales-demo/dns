terraform {
  required_version = ">= 1.5"

  required_providers {
    xcsh = {
      source = "f5-sales-demo/xcsh"
      # >= 3.62.0: release where the namespace attribute for system-only DNS
      # resources defaults to "system" (spec-driven), so it can be omitted.
      # Locally the provider is consumed via dev_overrides, which ignores this.
      version = ">= 3.62.0"
    }
  }
}
