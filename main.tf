locals {
  all_worker_nodes = flatten([for nodes in [var.worker_nodes, var.storage_nodes] :
    [for addr in nodes.ips : {
      "disk_size" = nodes.disk_size
      "memory"    = nodes.memory
      "num_cpu"   = nodes.num_cpu
      "slug"      = nodes.slug
      "ipv4_address" = addr }
  ] if nodes != null])

}

data "vsphere_virtual_machine" "template" {
  name          = var.rhcos_template
  datacenter_id = data.vsphere_datacenter.dc.id
}


module "master" {
  source    = "./modules/rhcos-static"
  count     = length(var.master_nodes.ips)
  name      = "${var.cluster_slug}-master-${count.index + 1}"
  folder    = vsphere_folder.folder.path
  datastore = data.vsphere_datastore.nvme.id
  disk_size = var.master_nodes.disk_size
  memory    = var.master_nodes.memory
  num_cpu   = var.master_nodes.num_cpu
  ignition  = file(var.master_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.dns[0]
  # TODO var.local_dns
  gateway      = var.gateway
  ipv4_address = var.master_nodes.ips[count.index]
  netmask      = var.netmask
}

module "worker" {
  source    = "./modules/rhcos-static"
  count     = length(local.all_worker_nodes)
  name      = "${var.cluster_slug}-wrk-${local.all_worker_nodes[count.index].slug}-${count.index + 1}"
  folder    = vsphere_folder.folder.path
  datastore = data.vsphere_datastore.nvme.id
  disk_size = local.all_worker_nodes[count.index].disk_size
  memory    = local.all_worker_nodes[count.index].memory
  num_cpu   = local.all_worker_nodes[count.index].num_cpu
  ignition  = file(var.worker_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.dns[0] # TODO var.local_dns
  gateway        = var.gateway
  ipv4_address   = local.all_worker_nodes[count.index].ipv4_address
  netmask        = var.netmask
}

module "bootstrap" {
  source    = "./modules/rhcos-static"
  count     = var.bootstrap_complete ? 0 : 1
  name      = "${var.cluster_slug}-bootstrap"
  folder    = vsphere_folder.folder.path
  datastore = data.vsphere_datastore.nvme.id
  disk_size = 40
  memory    = 8192
  num_cpu   = 16
  ignition  = file(var.bootstrap_ignition_path)

  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned

  network      = data.vsphere_network.network.id
  adapter_type = data.vsphere_virtual_machine.template.network_interface_types[0]

  cluster_domain = var.cluster_domain
  machine_cidr   = var.machine_cidr
  dns_address    = var.dns[0] # TODO var.local_dns
  gateway        = var.gateway
  ipv4_address   = var.bootstrap_ip
  netmask        = var.netmask
}

# TODO: Needs Parent folder
#resource "vsphere_folder" "folder" {
#  path          = "${var.vmware_folder}/${var.cluster_slug}"
#  type          = "vm"
#  datacenter_id = data.vsphere_datacenter.dc.id
#}

resource "vsphere_folder" "folder" {
  path          = "foo" // ${var.vmware_folder}/${var.cluster_slug}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "local_file" "pull_secret" {
  filename = "${path.module}/pull-secret.json"
}

data "template_file" "install-config" {
  template = file("${path.module}/install-config-tmpl.yaml")
  vars = {
    cluster_domain = "${var.cluster_domain}"
    # TODO : Do does the ocp4 installer even need those?
    # If so, we should pull them from the environment
    vc                  = "127.0.0.1"
    vc_username         = "user"
    vc_password         = "pass"
    vc_datacenter       = var.vc_dc # "DC0"
    vc_defaultDatastore = var.vc_ds # "LocalDS_0"
    pullSecret          = data.local_file.pull_secret.content
    sshKey              = tls_private_key.ssh.public_key_openssh
    httpsProxy          = "127.0.0.1"
  }
}

resource "local_file" "install-config" {
  content         = data.template_file.install-config.rendered
  file_permission = 0644
  filename        = "${path.module}/install-config.yaml"
}

# output "ign" {
#   value = module.lb.ignition
# }

# RSA key of size 4096 bits
#resource "tls_private_key" "rsa" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}

# ED25519 key - appears preferred by openshift
resource "tls_private_key" "ed25519" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "main" {
  private_key_pem = tls_private_key.ed25519.private_key_pem
  # file("private_key.pem")
  # private_key_pem = file("private_key.pem")

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }
}

# openssl req -noout -text -in csr-main.pem
resource "local_file" "csr-main" {
  content         = tls_cert_request.main.cert_request_pem
  file_permission = 0644
  filename        = "${path.module}/csr-main.pem"
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

