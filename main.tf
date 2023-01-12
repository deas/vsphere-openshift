locals {
  all_worker_nodes = flatten([for nodes in var.worker_nodes :
    [for i, addr in nodes.ips : {
      disk_size    = nodes.disk_size
      memory       = nodes.memory
      num_cpu      = nodes.num_cpu
      slug         = nodes.slug
      netmask      = nodes.netmask
      gateway      = nodes.gateway
      network      = nodes.network
      machine_cidr = nodes.machine_cidr
      attachments  = try(nodes.attachments[i], [])
      ipv4_address = addr }
  ] if nodes != null])
  networks      = toset(concat([var.master_nodes.network], [for nodes in var.worker_nodes : nodes.network]))
  dns_address   = join(":", var.dns)
  ignition_path = data.external.ignition.result.path # var.ignition_path
  ignition_gen = length(var.ignition_gen) > 0 ? var.ignition_gen : ["sh", "-c", format(<<EOT
rm -rf *.ign && "%s/generate-configs.sh" && echo '{"path":"'$(pwd)'"}'
EOT
    , abspath(path.module))
  ]
}

data "vsphere_datacenter" "dc" {
  name = var.vc_dc
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.vc_cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

/*
data "vsphere_network" "network" { # TODO : Rename for master
  name          = var.vc_network
  datacenter_id = data.vsphere_datacenter.dc.id
}
*/

data "vsphere_network" "nodes" {
  for_each      = local.networks
  name          = each.value
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "this" {
  name          = var.vc_ds
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.cos_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# TODO: Could be conditional if full config gets passed in
data "template_file" "install_config" {
  template = file("${path.module}/install-config-tmpl.yaml")
  vars = merge(
    {
      cluster_domain = var.cluster_domain
      name           = var.cluster_slug
    },
    {
      for k, v in var.ignition_vars : k => v if v != null
    },
    {
      vc_defaultDatastore = var.vc_ds
      pullSecret          = file("${path.module}/pull-secret-fake.json") # default
  })
}

resource "local_file" "install_config" {
  content         = data.template_file.install_config.rendered
  file_permission = 0644
  filename        = "${var.ignition_path}/install-config.yaml"
}

#data "local_file" "pull_secret" {
#  filename = var.ignition_vars.pullSecret
#}

data "external" "ignition" {
  program     = local.ignition_gen
  depends_on  = [local_file.install_config]
  working_dir = var.ignition_path
}

module "master" {
  source           = "./modules/cos-static" # TODO We should allow dynamic / consolidate cos modules
  count            = length(var.master_nodes.ips)
  name             = "${var.cluster_slug}-master-${count.index + 1}"
  folder           = var.vc_vm_folder
  datastore        = data.vsphere_datastore.this.id
  disk_size        = var.master_nodes.disk_size
  memory           = var.master_nodes.memory
  num_cpu          = var.master_nodes.num_cpu
  ignition         = file("${local.ignition_path}/master.ign")
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  network          = data.vsphere_network.nodes[var.master_nodes.network].id
  adapter_type     = data.vsphere_virtual_machine.template.network_interface_types[0]
  cluster_domain   = var.cluster_domain
  machine_cidr     = var.master_nodes.machine_cidr
  dns_address      = local.dns_address
  gateway          = var.master_nodes.gateway
  ipv4_address     = var.master_nodes.ips[count.index]
  netmask          = var.master_nodes.netmask
}

module "worker" {
  source           = "./modules/cos-static"
  count            = length(local.all_worker_nodes)
  ignition         = file("${local.ignition_path}/worker.ign")
  name             = "${var.cluster_slug}-wrk-${local.all_worker_nodes[count.index]["slug"]}-${count.index + 1}"
  folder           = var.vc_vm_folder
  datastore        = data.vsphere_datastore.this.id
  disk_size        = local.all_worker_nodes[count.index]["disk_size"]
  memory           = local.all_worker_nodes[count.index]["memory"]
  num_cpu          = local.all_worker_nodes[count.index]["num_cpu"]
  disk_attachments = local.all_worker_nodes[count.index]["attachments"]
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  network          = data.vsphere_network.nodes[local.all_worker_nodes[count.index]["network"]].id
  adapter_type     = data.vsphere_virtual_machine.template.network_interface_types[0]
  gateway          = local.all_worker_nodes[count.index]["gateway"]
  machine_cidr     = local.all_worker_nodes[count.index]["machine_cidr"]
  ipv4_address     = local.all_worker_nodes[count.index]["ipv4_address"]
  netmask          = local.all_worker_nodes[count.index]["netmask"]
  dns_address      = local.dns_address
  cluster_domain   = var.cluster_domain
}

module "bootstrap" {
  source           = "./modules/cos-static"
  count            = var.bootstrap_complete ? 0 : 1
  name             = "${var.cluster_slug}-bootstrap"
  folder           = var.vc_vm_folder
  datastore        = data.vsphere_datastore.this.id
  disk_size        = var.bootstrap_disk_size
  memory           = var.bootstrap_memory
  num_cpu          = var.bootstrap_num_cpu
  ignition         = file("${local.ignition_path}/bootstrap.ign")
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  template         = data.vsphere_virtual_machine.template.id
  thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
  network          = data.vsphere_network.nodes[var.master_nodes.network].id # TODO: Should not borrow from master?
  adapter_type     = data.vsphere_virtual_machine.template.network_interface_types[0]
  cluster_domain   = var.cluster_domain
  machine_cidr     = var.master_nodes.machine_cidr
  dns_address      = local.dns_address
  gateway          = var.master_nodes.gateway
  ipv4_address     = var.bootstrap_ip
  netmask          = var.master_nodes.netmask
}

/*
resource "vsphere_folder" "folder" {
  path          = "${var.vm_root_folder}/${var.cluster_slug}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}
*/

output "kubeconfig" {
  value = file("${data.external.ignition.result.path}/auth/kubeconfig")
}

output "kubeadmin_password" {
  value     = file("${data.external.ignition.result.path}/auth/kubeadmin-password")
  sensitive = true
}

# terraform output -json cluster | jq '.bu["99-master-chrony.bu"]' -r
output "bu" {
  #type = map
  value = length(var.ntp_servers) > 0 ? {
    "99-worker-chrony.bu" = templatefile("${path.module}/assets/99-xxx-chrony.bu.tmpl", {
      servers   = var.ntp_servers
      node_type = "worker"
    })
    "99-master-chrony.bu" = templatefile("${path.module}/assets/99-xxx-chrony.bu.tmpl", {
      servers   = var.ntp_servers
      node_type = "master"
    })
  } : null
}
