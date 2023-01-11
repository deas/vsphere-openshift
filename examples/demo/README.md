# Example Usage of VSphere OpenShift Cluster Module

## Usage

> * This repo *requires* Terraform 0.13 or newer
> * Install `oc tools` with `make install-oc-tools`

0. TODO .envrc
1. Configure DNS - https://blog.ktz.me/configure-unbound-dns-for-openshift-4/ - if using CoreDNS this is optional.
3. Customize `terraform.tfvars` with any relevant configuration.
4. Run `make init` to initialize
5. Run `make apply` to create the VMs and generate/install ignition configs
6. Monitor install progress with `make wait-for-bootstrap`
7. Check and approve pending CSRs with `make get-csr` and `make approve-csr`
8. Run `make bootstrap-complete` to destroy the bootstrap VM
9. Run `make wait-for-install` and wait for the cluster install to complete
10. Enjoy!
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bootstrap\_complete | n/a | `string` | `"false"` | no |
| bootstrap\_ignition\_path | n/a | `string` | `"openshift/bootstrap.ign"` | no |
| bootstrap\_ip | n/a | `string` | `""` | no |
| cluster\_domain | n/a | `string` | n/a | yes |
| cluster\_slug | n/a | `string` | n/a | yes |
| cos\_template | n/a | `string` | n/a | yes |
| dns | n/a | `list(string)` | n/a | yes |
| https\_proxy | n/a | `string` | `""` | no |
| ignition\_gen | n/a | `list(string)` | <pre>[<br>  "sh",<br>  "-c",<br>  "rm -rf *.ign && ../../../generate-configs.sh && echo '{\"path\":\"openshift\"}'"<br>]</pre> | no |
| loadbalancer\_ip | n/a | `string` | `""` | no |
| master\_ignition\_path | n/a | `string` | `"openshift/master.ign"` | no |
| master\_nodes | n/a | <pre>object({<br>    disk_size    = number<br>    memory       = number<br>    num_cpu      = number<br>    machine_cidr = string<br>    netmask      = string<br>    gateway      = string<br>    network      = string<br>    ips          = list(string)<br>  })</pre> | `null` | no |
| no\_proxy | n/a | `string` | `""` | no |
| openshift\_gen | n/a | `string` | `"cd openshift && ../../../generate-configs.sh"` | no |
| proxy\_hosts | n/a | `list(string)` | n/a | yes |
| pull\_secret | n/a | `string` | `"../../pull-secret-fake.json"` | no |
| vc\_cluster | n/a | `string` | n/a | yes |
| vc\_dc | n/a | `string` | n/a | yes |
| vc\_ds | n/a | `string` | n/a | yes |
| vm\_folder | n/a | `string` | n/a | yes |
| worker\_ignition\_path | n/a | `string` | `"openshift/worker.ign"` | no |
| worker\_nodes | n/a | <pre>list(object({<br>    disk_size    = number<br>    memory       = number<br>    num_cpu      = number<br>    slug         = string<br>    machine_cidr = string<br>    netmask      = string<br>    gateway      = string<br>    network      = string<br>    attachments  = list(list(map(string)))<br>    ips          = list(string)<br>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster | n/a |
| openssh\_private\_key | terraform output -raw openssh\_private\_key |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
