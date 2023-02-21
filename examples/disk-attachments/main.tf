terraform {
  required_version = ">= 1.3"
}

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

module "disk_attachments" {
  source    = "../../modules/disk-attachments"
  vc_dc     = var.vc_dc
  disks     = var.disks
  base_path = var.base_path
}