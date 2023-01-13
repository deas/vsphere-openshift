# TODO: Here as depedendency `disks` argument should be pulled from worker nodes
module "disk_attachments" {
  source = "../../modules/disk-attachments"
  vc_dc  = var.vc_dc
  disks = { /*
    "bare-test" = {
      ds   = "LocalDS_0"
      size = 172
    }*/
  }
}

data "vsphere_datacenter" "dc" {
  name = var.vc_dc
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vc_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

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
  vc_vm_folder  = vsphere_folder.vm.path
  dns           = var.dns
  # proxy_hosts = var.proxy_hosts
  # ntp_servers    = var.ntp_servers
  bootstrap_ip   = var.bootstrap_ip
  master_nodes   = var.master_nodes
  worker_nodes   = var.worker_nodes
  cos_template   = var.cos_template
  cluster_slug   = var.cluster_slug
  cluster_domain = var.cluster_domain
  ntp_servers    = var.ntp_servers
  ignition_vars = {
    vc            = "127.0.0.1"
    vc_username   = "user"
    vc_password   = "password"
    vc_datacenter = var.vc_dc
    sshKey        = "" # var.public_key_openssh
    apiVIP        = "128.0.0.1"
    httpsProxy    = "http://localhost:3128" # optional(string)
    noProxy       = ".foo.bar"
    # ingressVIP = "128.0.0.1"
    # httpsProxy = "http://localhost:3128" # optional(string)
  }
  depends_on = [module.disk_attachments]
}

resource "vsphere_folder" "vm" {
  path          = var.vm_folder
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
    "bu" = module.cluster.bu
  }
}

output "kubeadmin_password" {
  value     = module.cluster.kubeadmin_password
  sensitive = true
}

output "api_endpoint" {
  value = module.cluster.api_endpoint
}

output "ingress_domain" {
  value = module.cluster.ingress_domain
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
