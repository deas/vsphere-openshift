variable "vc_dc" {
  type = string
}

variable "vc_cluster" {
  type = string
}

variable "vc_ds" {
  type = string
}
/*
variable "vc_network" {
  type = string
}
*/

###########################
## OCP Cluster Vars

variable "cluster_slug" {
  type = string
}

variable "vm_folder" {
  type = string
}

################
## VMware vars - unlikely to need to change between releases of OCP
variable "cos_template" {
  type = string
}

/*
provider "vsphere" {
}
*/

variable "ignition_gen" {
  type    = list(string)
  default = ["sh", "-c", "rm -rf *.ign && ../../../tools/generate-configs.sh"]
}

variable "master_nodes" {
  type = object({
    disk_size    = number
    memory       = number
    num_cpu      = number
    machine_cidr = string
    netmask      = string
    gateway      = string
    network      = string
    ips          = list(string)
  })
  default = null
}

variable "worker_nodes" {
  type = list(object({
    disk_size    = number
    memory       = number
    num_cpu      = number
    slug         = string
    machine_cidr = string
    netmask      = string
    gateway      = string
    network      = string
    attachments  = list(list(map(string)))
    ips          = list(string)
  }))
  default = null
}

variable "bootstrap_ip" {
  type    = string
  default = ""
}

variable "cluster_domain" {
  type = string
}

/*
variable "machine_cidr" {
  type = string
}

variable "gateway" {
  type = string
}
*/

variable "dns" {
  type = list(string)
}

variable "ntp_servers" {
  type = list(string)
}