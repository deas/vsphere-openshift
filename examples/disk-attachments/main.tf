variable "disks" {
  type = map(object({
    size = number
    ds   = string
  }))
}

variable "vc_dc" {
  type = string
}

variable "base_path" {
  type = string
}

data "vsphere_datacenter" "dc" {
  name = var.vc_dc
}

module "disk_attachments" {
  source    = "../../modules/disk-attachments"
  vc_dc     = var.vc_dc
  disks     = var.disks
  base_path = var.base_path
}