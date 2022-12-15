variable "vc_dc" {
  type = string
}

variable "vc_cluster" {
  type = string
}

variable "vc_ds" {
  type = string
}

variable "vc_network" {
  type = string
}

###########################
## OCP Cluster Vars

variable "cluster_slug" {
  type = string
}

variable "vmware_folder" {
  type = string
}

variable "bootstrap_complete" {
  type    = string
  default = "false"
}
################
## VMware vars - unlikely to need to change between releases of OCP

variable "rhcos_template" {
  type = string
}

/*
provider "vsphere" {
}
*/

data "vsphere_datacenter" "dc" {
  name = var.vc_dc
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vc_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.vc_network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "nvme" {
  name          = var.vc_ds
  datacenter_id = data.vsphere_datacenter.dc.id
}

##########
## Ignition

#provider "ignition" {
# https://www.terraform.io/docs/providers/ignition/index.html
#  version = "1.2.1"
#}

variable "ignition" {
  type    = string
  default = ""
}

#########
## Machine variables
# Keeping those ignition paths as vars as we might want to delegate this to another module

variable "bootstrap_ignition_path" {
  type    = string
  default = "openshift/bootstrap.ign"
}

variable "master_ignition_path" {
  type    = string
  default = "openshift/master.ign"
}

variable "worker_ignition_path" {
  type    = string
  default = "openshift/worker.ign"
}

variable "master_nodes" {
  type = object({
    disk_size = number
    memory    = number
    num_cpu   = number
    ips       = list(string)
  })
  default = null
}

variable "worker_nodes" {
  type = object({
    disk_size = number
    memory    = number
    num_cpu   = number
    slug      = string
    ips       = list(string)
  })
  default = null
}

variable "storage_nodes" {
  type = object({
    disk_size = number
    memory    = number
    num_cpu   = number
    slug      = string
    ips       = list(string)
  })
  default = null
}

variable "bootstrap_ip" {
  type    = string
  default = ""
}

variable "loadbalancer_ip" {
  type    = string
  default = ""
}

variable "cluster_domain" {
  type = string
}

variable "machine_cidr" {
  type = string
}

variable "gateway" {
  type = string
}

variable "dns" {
  type = list(string)
}

variable "ntp_servers" {
  type = list(string)
}

variable "proxy_hosts" {
  type = list(string)
}

variable "netmask" {
  type = string
}
