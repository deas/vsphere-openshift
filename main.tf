locals {
  all_worker_nodes = flatten([for nodes in [var.worker_nodes, var.storage_nodes] :
    [for addr in nodes.ips : {
      "disk_size" = nodes.disk_size
      "memory"    = nodes.memory
      "num_cpu"   = nodes.num_cpu
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
  name      = "${var.cluster_slug}-master${count.index + 1}"
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
  dns_address    = var.dns # var.local_dns
  gateway        = var.gateway
  ipv4_address   = var.master_nodes.ips[count.index]
  netmask        = var.netmask
}

module "worker" {
  source    = "./modules/rhcos-static"
  count     = length(local.all_worker_nodes)
  name      = "${var.cluster_slug}-worker${count.index + 1}"
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
  dns_address    = var.dns # local_dns
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
  dns_address    = var.dns # local_dns
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


# output "ign" {
#   value = module.lb.ignition
# }

