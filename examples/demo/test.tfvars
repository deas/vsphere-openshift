# openshift_gen="touch openshift/bootstrap.ign && touch openshift/master.ign && touch openshift/worker.ign"

vc_dc      = "DC0"
vc_cluster = "DC0_C0"
vc_ds      = "LocalDS_0"
# vc_network = "VM Network" # TODO: Should probably be named master

ignition_gen = ["sh", "-c", <<EOT
../../tools/generate-configs-mock.sh
EOT
]
/*
ignition_gen = ["sh", "-c", <<EOT
dir=$(mktemp -d --suffix -okd)
cd $${dir}
cat > install-config.yaml 
# jq -r .install_config > install-config.yaml 
rm -rf *.ign && \
mkdir -p auth && \
echo 'test' > auth/kubeconfig && \
echo 'test' > auth/kubeadmin-password && \
touch bootstrap.ign && \
touch master.ign && \
touch worker.ign && \
touch metadata.json && \
echo '{"path": "'$${dir}'"}'
EOT
]
*/

dns = ["10.101.2.1", "10.111.2.1", "10.101.2.2"]
# gateway = "10.126.20.1"
# loadbalancer_ip = "192.168.5.160"
proxy_hosts = ["http://...:8080", "https://...:8080"]
ntp_servers = ["ntp_1", "ntp_2"]

# "vlan_id" = 1263
#machine_cidr = "10.126.20.0/24"
# netmask      = "255.255.255.0"
bootstrap_ip = "10.126.20.4"

master_nodes = {
  "disk_size"    = 128
  "memory"       = 16384
  "num_cpu"      = 4
  "machine_cidr" = "10.126.20.0/24"
  "netmask"      = "255.255.255.0"
  "gateway"      = "10.126.20.1"
  "network"      = "DC0_DVPG0"
  "ips"          = ["10.126.20.5", "10.126.20.6", "10.126.20.7"]
}
worker_nodes = [
  {
    "disk_size"    = 128
    "memory"       = 32768
    "num_cpu"      = 4
    "slug"         = "default"
    "machine_cidr" = "10.126.20.0/24"
    "netmask"      = "255.255.255.0"
    "gateway"      = "10.126.20.1"
    "network"      = "DC0_DVPG0"
    "attachments"  = []
    "ips"          = ["10.126.20.32", "10.126.20.33", "10.126.20.34"]
  },
  {
    "disk_size"    = 128
    "memory"       = 32768 # TODO: 38 # ??
    "num_cpu"      = 10
    "slug"         = "storage"
    "machine_cidr" = "10.126.20.0/24"
    "netmask"      = "255.255.255.0"
    "gateway"      = "10.126.20.1"
    "network"      = "DC0_DVPG0"
    "attachments"  = [] # TODO: Disks not supported by vscim - yet
    /* "attachments" = [[
      {
        path         = "/path-1-1.vmdk"
        datastore_id = "LocalDS_0"
      },
      {
        path         = "/path-1-2.vmdk"
        datastore_id = "LocalDS_0"
      }
      ], [
      {
        path         = "/path-2-1.vmdk"
        datastore_id = "LocalDS_0"
      },
      {
        path         = "/path-2-2.vmdk"
        datastore_id = "LocalDS_0"
      }
      ], [
      {
        path         = "/path-3-1.vmdk"
        datastore_id = "LocalDS_0"
      },
      {
        path         = "/path-3-2.vmdk"
        datastore_id = "LocalDS_0"
      }
    ]] */
    "ips" = ["10.126.20.8", "10.126.20.9", "10.126.20.10"]
  }
]

## Cluster configuration
vm_folder = "okd"
# rhcos_template = "rhcos-4.9.0" # TODO
cos_template   = "DC0_H0_VM0"
cluster_slug   = "mgmt"
cluster_domain = "openshift.lab.int" # TODO
