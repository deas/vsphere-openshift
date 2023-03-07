locals {
  ignition_encoded = "data:text/plain;charset=utf-8;base64,${base64encode(var.ignition)}"
}

data "ignition_file" "hostname" {

  path = "/etc/hostname"
  mode = "775"

  content {
    content = var.name
  }
}

data "ignition_config" "vm" {

  merge {
    source = local.ignition_encoded
  }
  files = [
    data.ignition_file.hostname.rendered
  ]
}

resource "vsphere_virtual_machine" "vm" {

  name             = var.name
  resource_pool_id = var.resource_pool_id
  datastore_id     = var.datastore
  num_cpus         = var.num_cpu
  memory           = var.memory
  # memory_reservation          = var.memory
  guest_id                    = var.guest_id
  folder                      = var.folder
  enable_disk_uuid            = "true"
  wait_for_guest_net_timeout  = "0"
  wait_for_guest_net_routable = "false"
  # swap_placement_policy       = "inherit"
  lifecycle {
    ignore_changes = [extra_config /*, swap_placement_policy*/] # Hack to prevent update which appears to mess up the vm
  }
  network_interface {
    network_id   = var.network
    adapter_type = var.adapter_type
  }
  disk {
    label            = "disk0"
    size             = var.disk_size
    thin_provisioned = var.thin_provisioned
    # TODO datastore_id = "fixme"
  }

  // TODO: Quick hack - we might want to migrate to terraform-vsphere-vm
  dynamic "disk" {
    for_each = var.disk_attachments # var.content_library == null ? data.vsphere_virtual_machine.template[0].disks : []
    iterator = att
    content {
      label        = /*length(var.disk_label) > 0 ? var.disk_label[att.key] : */ "att-disk-${att.key}"
      attach       = true
      datastore_id = att.value.datastore_id
      path         = att.value.path
      unit_number  = 1 + att.key
      #label             = length(var.disk_label) > 0 ? var.disk_label[disks.key] : "disk${disks.key}"
      #size              = var.disk_size_gb != null ? var.disk_size_gb[disks.key] : data.vsphere_virtual_machine.template[0].disks[disks.key].size
      #unit_number       = var.scsi_controller != null ? var.scsi_controller * 15 + disks.key : disks.key
      #thin_provisioned  = data.vsphere_virtual_machine.template[0].disks[disks.key].thin_provisioned
      #eagerly_scrub     = data.vsphere_virtual_machine.template[0].disks[disks.key].eagerly_scrub
      #datastore_id      = var.disk_datastore != "" ? data.vsphere_datastore.disk_datastore[0].id : null
      #storage_policy_id = length(var.template_storage_policy_id) > 0 ? var.template_storage_policy_id[disks.key] : null
      #io_reservation    = length(var.io_reservation) > 0 ? var.io_reservation[disks.key] : null
      #io_share_level    = length(var.io_share_level) > 0 ? var.io_share_level[disks.key] : "normal"
      #io_share_count    = length(var.io_share_level) > 0 && var.io_share_level[disks.key] == "custom" ? var.io_share_count[disks.key] : null
    }
  }

  clone {
    template_uuid = var.template
  }

  extra_config = {
    "guestinfo.ignition.config.data"          = base64encode(data.ignition_config.vm.rendered)
    "guestinfo.ignition.config.data.encoding" = "base64"

    # configures the static IP
    # https://www.man7.org/linux/man-pages/man7/dracut.cmdline.7.html
    "guestinfo.afterburn.initrd.network-kargs" = "ip=${var.ipv4_address}::${var.gateway}:${var.netmask}:${var.name}:ens192:off:${var.dns_address}"
  }

  // Advanced options
  hv_mode                          = var.hv_mode
  ept_rvi_mode                     = var.ept_rvi_mode
  nested_hv_enabled                = var.nested_hv_enabled
  enable_logging                   = var.enable_logging
  cpu_performance_counters_enabled = var.cpu_performance_counters_enabled
  swap_placement_policy            = var.swap_placement_policy
  latency_sensitivity              = var.latency_sensitivity
  shutdown_wait_timeout            = var.shutdown_wait_timeout
  force_power_off                  = var.force_power_off
}
