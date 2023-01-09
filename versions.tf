terraform {
  #required_providers {
  #  vsphere = "~> 2.2"
  #  local   = "~> 2.2"
  #}
  required_providers {
    external = {
      version = "~> 2.2"
    }
    template = {
      version = "~> 2.2"
    }
    local = {
      version = "~> 2.2"
    }
    ignition = {
      source = "terraform-providers/ignition"
    }
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.2"

    }
  }
  required_version = ">= 1.3"
}
