variable "name" {
  type = string
}

variable "ignition" {
  type    = string
  default = ""
}

#variable "ignition_url" {
#  type    = string
#  default = ""
#}

variable "resource_pool_id" {
  type = string
}

variable "folder" {
  type = string
}

variable "datastore" {
  type = string
}

variable "network" {
  type = string
}

variable "adapter_type" {
  type = string
}

variable "guest_id" {
  type = string
}

variable "template" {
  type = string
}

variable "thin_provisioned" {
  type = string
}

variable "disk_size" {
  type = string
}

variable "memory" {
  type = string
}

variable "num_cpu" {
  type = string
}

#variable "cluster_domain" {
#  type = string
#}

#variable "machine_cidr" {
#  type = string
#}

variable "gateway" {
  type = string
}

variable "ipv4_address" {
  type = string
}

variable "netmask" {
  type = string
}

variable "dns_address" {
  type = string
}

variable "disk_attachments" {
  type    = list(any) #(map(string))
  default = []
}

// Borrowed from https://github.com/Terraform-VMWare-Modules/terraform-vsphere-vm
// We should probably borrow the whole module
variable "hv_mode" {
  description = "The (non-nested) hardware virtualization setting for this virtual machine. Can be one of hvAuto, hvOn, or hvOff."
  type        = string
  default     = null
}

variable "ept_rvi_mode" {
  description = "The EPT/RVI (hardware memory virtualization) setting for this virtual machine."
  type        = string
  default     = null
}

variable "nested_hv_enabled" {
  description = "Enable nested hardware virtualization on this virtual machine, facilitating nested virtualization in the guest."
  type        = bool
  default     = null
}

variable "enable_logging" {
  description = "Enable logging of virtual machine events to a log file stored in the virtual machine directory."
  type        = bool
  default     = null
}

variable "cpu_performance_counters_enabled" {
  description = "Enable CPU performance counters on this virtual machine."
  type        = bool
  default     = null
}

variable "swap_placement_policy" {
  description = "The swap file placement policy for this virtual machine. Can be one of inherit, hostLocal, or vmDirectory."
  type        = string
  default     = null
}

variable "latency_sensitivity" {
  description = "Controls the scheduling delay of the virtual machine. Use a higher sensitivity for applications that require lower latency, such as VOIP, media player applications, or applications that require frequent access to mouse or keyboard devices.Can be one of low, normal, medium, or high."
  type        = string
  default     = null
}

variable "shutdown_wait_timeout" {
  description = "The amount of time, in minutes, to wait for a graceful guest shutdown when making necessary updates to the virtual machine. If force_power_off is set to true, the VM will be force powered-off after this timeout, otherwise an error is returned."
  type        = string
  default     = null
}

variable "force_power_off" {
  description = "If a guest shutdown failed or timed out while updating or destroying (see shutdown_wait_timeout), force the power-off of the virtual machine."
  type        = bool
  default     = null
}