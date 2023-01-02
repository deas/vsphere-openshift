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

variable "vc_vm_folder" {
  type = string
}

###########################
## OCP Cluster Vars

variable "cluster_slug" {
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

#########
## Machine variables
# Keeping those ignition paths as vars as we might want to delegate this to another module

variable "ignition_path" {
  type = string
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
    ips         = list(string)
    attachments = list(list(map(string)))
  })
  default = null
}

variable "ignition_vars" {
  type = object({
    vc            = string # local.vc.server # "127.0.0.1"
    vc_username   = string # local.vc.username
    vc_password   = string # local.vc.password
    vc_datacenter = string # local.datacenter.name
    # vc_defaultDatastore = var.vc_ds
    pullSecret = optional(string) #, "") # file("${path.module}/pull-secret-fake.json"))
    # data.local_file.pull_secret.content
    sshKey     = string               # var.public_key_openssh
    apiVIP     = optional(string, "") # TODO: Check
    ingressVIP = optional(string, "") # TODO: Check
    httpsProxy = optional(string, "")
    noProxy    = optional(string, "")

  })
}

variable "ignition_gen" {
  type    = list(string)
  default = [] /*["sh", "-c", <<EOT
rm -rf *.ign && touch bootstrap.ign && touch master.ign && touch worker.ign && echo '{"path": "'$(pwd)'"}'
EOT
  ]*/
  # ] '$(pwd)'"}
  #  default = ["sh", "-c", <<EOT
  #rm -rf *.ign && ${path.module}/generate-configs.sh && echo '{"path":"'$(pwd)'"}'
  #EOT
  #  ]
}

variable "bootstrap_ip" {
  type = string
}


variable "bootstrap_disk_size" {
  type    = number
  default = 40
}

variable "bootstrap_memory" {
  type    = number
  default = 8192
}
variable "bootstrap_num_cpu" {
  type    = number
  default = 4 # 16 ? WTF?
}

/*
variable "loadbalancer_ip" {
  type = string
}
*/

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
