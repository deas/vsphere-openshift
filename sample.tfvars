vc_dc      = "DC0"
vc_cluster = "DC0_C0"
vc_ds      = "LocalDS_0"
vc_network = "VM Network"

dns     = ["10.101.2.1", "10.111.2.1", "10.101.2.2"]
gateway = "10.126.20.1" # TODO ?
# loadbalancer_ip = "192.168.5.160"
proxy_hosts = ["http://...:8080", "https://...:8080"]
ntp_servers = ["dns_name_1", "dns_name_2"]

# "vlan_id" = 1263
machine_cidr = "10.126.20.0/24"
netmask      = "255.255.255.0"
bootstrap_ip = "10.126.20.4"

master_nodes = {
  "disk_size" = 128
  "memory"    = 16384
  "num_cpu"   = 4
  "ips"       = ["10.126.20.5", "10.126.20.6", "10.126.20.7"]
}

storage_nodes = {
  "disk_size" = 128
  "memory"    = 32768 # TODO: 38 # ??
  "num_cpu"   = 10
  "ips"       = ["10.126.20.8", "10.126.20.9", "10.126.20.10"]
}

worker_nodes = {
  "disk_size" = 128
  "memory"    = 32768
  "num_cpu"   = 4
  "ips"       = ["10.126.20.32", "10.126.20.33", "10.126.20.34"]
}

## Cluster configuration
vmware_folder = "redhat/openshift"
# rhcos_template = "rhcos-4.9.0" # TODO
rhcos_template = "DC0_H0_VM0"
cluster_slug   = "mgmt"
cluster_domain = "openshift.lab.int" # TODO

## Expects `openshift-install create ignition-configs` to have been run
## probably via generate-configs.sh
bootstrap_ignition_path = "./openshift/bootstrap.ign"
master_ignition_path    = "./openshift/master.ign"
worker_ignition_path    = "./openshift/worker.ign"
