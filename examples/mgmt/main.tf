data "vsphere_datacenter" "dc" {
  name = var.vc_dc
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vc_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

/*
data "vsphere_network" "network" {
  name          = var.vc_network
  datacenter_id = data.vsphere_datacenter.dc.id
}
*/

data "vsphere_datastore" "nvme" {
  name          = var.vc_ds
  datacenter_id = data.vsphere_datacenter.dc.id
}

module "tls" {
  source       = "../../modules/tls"
  sub_domain   = "${var.cluster_slug}.${var.cluster_domain}"
  organization = "Example Something"
}

module "cluster" {
  source        = "../.."
  ignition_path = abspath("${path.module}/openshift")
  ignition_gen  = var.ignition_gen
  vc_dc         = var.vc_dc
  vc_cluster    = var.vc_cluster
  vc_ds         = var.vc_ds
  # vc_network    = var.vc_network
  vc_vm_folder = vsphere_folder.vm.path
  dns          = var.dns
  # gateway       = var.gateway
  proxy_hosts = var.proxy_hosts
  ntp_servers = var.ntp_servers
  # machine_cidr  = var.machine_cidr
  # netmask       = var.netmask
  bootstrap_ip = var.bootstrap_ip
  master_nodes = var.master_nodes
  # storage_nodes  = var.storage_nodes
  worker_nodes   = var.worker_nodes
  cos_template   = var.cos_template
  cluster_slug   = var.cluster_slug
  cluster_domain = var.cluster_domain
  ignition_vars = {
    vc            = "127.0.0.1"
    vc_username   = "user"
    vc_password   = "password"
    vc_datacenter = var.vc_dc
    # pullSecret = optional(string, file("${path.module}/pull-secret-fake.json"))
    sshKey = "" # var.public_key_openssh
    apiVIP = "128.0.0.1"
    # ingressVIP = "128.0.0.1"
    # httpsProxy = optional(string)
  }
  # loadbalancer_ip = var.loadbalancer_ip
  # depends_on      = [data.external.ignition_files]
}

resource "vsphere_folder" "vm" {
  path          = var.vm_folder // TODO ${var.vmware_folder}/${var.cluster_slug}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

// terraform output -raw openssh_private_key
output "openssh_private_key" {
  value     = tls_private_key.ssh.private_key_openssh
  sensitive = true
}

output "cluster" {
  value = {
    "kubeconfig" = module.cluster.kubeconfig
  }
}

/*
output tls_private_key {
  value = tls_private_key.ed25519.private_key_pem
}
*/


# RSA key of size 4096 bits
#resource "tls_private_key" "rsa" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}
