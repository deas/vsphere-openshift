variable "pull_secret" {
  type = string
  # https://github.com/okd-project/okd/issues/182
  default = "../../pull-secret-fake.json"
}
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

variable "vm_folder" {
  type = string
}

variable "bootstrap_complete" {
  type    = string
  default = "false"
}
################
## VMware vars - unlikely to need to change between releases of OCP

variable "cos_template" {
  type = string
}

variable "openshift_gen" {
  type = string
  # default = "touch openshift/bootstrap.ign && touch openshift/master.ign && touch openshift/worker.ign"
  default = "cd openshift && ../../../generate-configs.sh"
}

/*
provider "vsphere" {
}
*/

##########
## Ignition

#provider "ignition" {
# https://www.terraform.io/docs/providers/ignition/index.html
#  version = "1.2.1"
#}

#variable "ignition" {
#  type    = string
#  default = ""
#}

variable "https_proxy" {
  type    = string
  default = ""
}

variable "no_proxy" {
  type    = string
  default = ""
}

variable "ignition_gen" {
  type    = list(string)
  default = ["sh", "-c", "rm -rf *.ign && ../../../generate-configs.sh && echo '{\"path\":\"openshift\"}'"]
}

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
    disk_size   = number
    memory      = number
    num_cpu     = number
    slug        = string
    attachments = list(list(map(string)))
    ips         = list(string)
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
