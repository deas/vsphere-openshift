terraform {
  required_providers {
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "~> 2.1"
    }
  }
  required_version = ">= 1.3"
}
