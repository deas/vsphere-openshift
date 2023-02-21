terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.2"
    }
  }
  required_version = ">= 1.3"
}
