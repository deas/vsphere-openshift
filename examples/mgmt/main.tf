module "cluster" {
  source          = "../.."
  ignition_path   = "${path.module}/openshift"
  vc_dc           = var.vc_dc
  vc_cluster      = var.vc_cluster
  vc_ds           = var.vc_ds
  vc_network      = var.vc_network
  dns             = var.dns
  gateway         = var.gateway
  loadbalancer_ip = var.loadbalancer_ip
  proxy_hosts     = var.proxy_hosts
  ntp_servers     = var.ntp_servers
  machine_cidr    = var.machine_cidr
  netmask         = var.netmask
  bootstrap_ip    = var.bootstrap_ip
  master_nodes    = var.master_nodes
  storage_nodes   = var.storage_nodes
  worker_nodes    = var.worker_nodes
  vmware_folder   = var.vmware_folder
  rhcos_template  = var.rhcos_template
  cluster_slug    = var.cluster_slug
  cluster_domain  = var.cluster_domain
  // sshKey              = tls_private_key.ssh.public_key_openssh
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


data "template_file" "install_config" {
  template = file("../../install-config-tmpl.yaml")
  vars = {
    cluster_domain = "${var.cluster_domain}"
    # TODO : Do does the ocp4 installer even need those?
    # If so, we should pull them from the environment
    vc                  = "127.0.0.1"
    vc_username         = "user"
    vc_password         = "pass"
    vc_datacenter       = var.vc_dc # "DC0"
    vc_defaultDatastore = var.vc_ds # "LocalDS_0"
    name                = var.cluster_slug
    pullSecret          = data.local_file.pull_secret.content
    sshKey              = tls_private_key.ssh.public_key_openssh
    httpsProxy          = "127.0.0.1"
  }
}

resource "local_file" "install_config" {
  content         = data.template_file.install_config.rendered
  file_permission = 0644
  filename        = "${path.module}/openshift/install-config.yaml"
}

data "local_file" "pull_secret" {
  filename = "${path.module}/pull-secret.json"
}

resource "null_resource" "ocp4_config" {
  #triggers = {
  #  always_run = "${timestamp()}"
  #  # file_changed = md5(local_file.backup_file.content)
  #  # value = var.some_id
  #}

  provisioner "local-exec" {
    command = <<EOT
      cd openshift && ../../../generate-configs.sh
    EOT
  }
  depends_on = [
    local_file.install_config
  ]
}


# RSA key of size 4096 bits
#resource "tls_private_key" "rsa" {
#  algorithm = "RSA"
#  rsa_bits  = 4096
#}