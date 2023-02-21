# VSphere OpenShift - Reusable UPI Tooling

This repo aims at providing tools helping with terraform based UPI of OpenShift/OKD on VSphere.

It is based on [`ironicbadger/ocp4`](https://github.com/ironicbadger/ocp4). You may want to check the writup on [openshift.com](https://www.openshift.com/blog/how-to-install-openshift-4.6-on-vmware-with-upi).

Contrary to its parent, this repo focuses on reusability and primarily targets OKD. We aim at compatibility with Redhat OpenShift, but at the time of writing, we don't have such an environment.

## Usage
The main terraform module is at the root of the repository. It covers a single cluster. An example how it may be used can be found in [`examples/demo`](./examples/demo).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bootstrap\_complete | n/a | `string` | `"false"` | no |
| bootstrap\_disk\_size | n/a | `number` | `40` | no |
| bootstrap\_ip | n/a | `string` | n/a | yes |
| bootstrap\_memory | n/a | `number` | `8192` | no |
| bootstrap\_num\_cpu | n/a | `number` | `4` | no |
| cluster\_domain | n/a | `string` | n/a | yes |
| cluster\_slug | n/a | `string` | n/a | yes |
| cos\_template | n/a | `string` | n/a | yes |
| dns | n/a | `list(string)` | n/a | yes |
| ignition\_gen | n/a | `list(string)` | `[]` | no |
| ignition\_path | n/a | `string` | n/a | yes |
| ignition\_vars | n/a | <pre>object({<br>    vc            = string<br>    vc_username   = string<br>    vc_password   = string<br>    vc_datacenter = string<br>    # vc_defaultDatastore = var.vc_ds<br>    pullSecret = optional(string) #, "") # file("${path.module}/pull-secret-fake.json"))<br>    # data.local_file.pull_secret.content<br>    sshKey     = string<br>    apiVIP     = optional(string, "") # TODO: Check<br>    ingressVIP = optional(string, "") # TODO: Check<br>    httpsProxy = optional(string, "")<br>    noProxy    = optional(string, "")<br><br>  })</pre> | n/a | yes |
| master\_nodes | TODO: Might make sense to condense into single nodes list | <pre>object({<br>    disk_size    = number<br>    memory       = number<br>    num_cpu      = number<br>    ips          = list(string)<br>    machine_cidr = string<br>    netmask      = string<br>    gateway      = string<br>    network      = string<br>  })</pre> | `null` | no |
| ntp\_servers | n/a | `list(string)` | `[]` | no |
| vc\_cluster | n/a | `string` | n/a | yes |
| vc\_dc | n/a | `string` | n/a | yes |
| vc\_ds | n/a | `string` | n/a | yes |
| vc\_vm\_folder | n/a | `string` | n/a | yes |
| worker\_nodes | n/a | <pre>list(object({<br>    disk_size    = number<br>    memory       = number<br>    num_cpu      = number<br>    slug         = string<br>    network      = string<br>    ips          = list(string)<br>    machine_cidr = string<br>    netmask      = string<br>    gateway      = string<br>    network      = string<br>    attachments  = list(list(map(string)))<br>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_endpoint | n/a |
| bu | terraform output -json cluster \| jq '.bu["99-master-chrony.bu"]' -r |
| ingress\_domain | n/a |
| kubeadmin\_password | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## TODO
- Bits that should be worked on are marked with `TODO` tags.
- [VCSim does not support QueryVirtualDiskInfo_Task #3000](https://github.com/vmware/govmomi/issues/3000)
- `Error: error fetching DVS after creation: ServerFaultCode: The object has already been deleted or has not been completely created`
- `Error: could not find DVS "50 2c 0e c6 65 64 60 98-43 b8 ff 56 1c 19 1d 56": ServerFaultCode: DistributedVirtualSwitchManager:DVSManager does not implement: QueryDvsByUuid`
