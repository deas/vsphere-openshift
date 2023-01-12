variable "vc_dc" {
  type = string
}

variable "vc_cluster" {
  type = string
}

variable "vc_ds" {
  type = string
}

variable "vc_vm_folder" {
  type = string
}

variable "cluster_slug" {
  type = string
}

variable "bootstrap_complete" {
  type    = string
  default = "false"
}

variable "cos_template" {
  type = string
}

## Machine variables
# Keeping those ignition paths as vars as we might want to delegate this to another module

variable "ignition_path" {
  type = string
}

# TODO: Might make sense to condense into single nodes list
variable "master_nodes" {
  type = object({
    disk_size    = number
    memory       = number
    num_cpu      = number
    ips          = list(string)
    machine_cidr = string
    netmask      = string
    gateway      = string
    network      = string
  })
  default = null
}

variable "worker_nodes" {
  type = list(object({
    disk_size    = number
    memory       = number
    num_cpu      = number
    slug         = string
    network      = string
    ips          = list(string)
    machine_cidr = string
    netmask      = string
    gateway      = string
    network      = string
    attachments  = list(list(map(string)))
  }))
  default = null
}

variable "ignition_vars" {
  type = object({
    vc            = string
    vc_username   = string
    vc_password   = string
    vc_datacenter = string
    # vc_defaultDatastore = var.vc_ds
    pullSecret = optional(string) #, "") # file("${path.module}/pull-secret-fake.json"))
    # data.local_file.pull_secret.content
    sshKey     = string
    apiVIP     = optional(string, "") # TODO: Check
    ingressVIP = optional(string, "") # TODO: Check
    httpsProxy = optional(string, "")
    noProxy    = optional(string, "")

  })
}

variable "ignition_gen" {
  type    = list(string)
  default = []
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

variable "cluster_domain" {
  type = string
}

variable "dns" {
  type = list(string)
}

variable "ntp_servers" {
  type    = list(string)
  default = []
}

#variable "proxy_hosts" {
#  type = list(string)
#}
