terraform {
  required_providers {
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "~> 2.1"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.2"
    }
  }
  required_version = ">= 1.3"
}
