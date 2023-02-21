terraform {
  required_version = ">= 1.3"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.2"
    }
  }
}

variable "vc_dc" {
  type = string
}

variable "base_path" {
  type    = string
  default = ""
}

variable "disks" {
  type = map(object({
    size = number
    ds   = string
  }))
}

resource "vsphere_virtual_disk" "this" {
  for_each           = var.disks
  size               = each.value.size
  type               = "thin"
  vmdk_path          = format("%s/%s.vmdk", var.base_path, each.key)
  create_directories = true
  datacenter         = var.vc_dc
  datastore          = each.value.ds
}
