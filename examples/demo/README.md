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
| bootstrap\_ip | n/a | `string` | `""` | no |
| cluster\_domain | n/a | `string` | n/a | yes |
| cluster\_slug | n/a | `string` | n/a | yes |
| cos\_template | ############### # VMware vars - unlikely to need to change between releases of OCP | `string` | n/a | yes |
| dns | n/a | `list(string)` | n/a | yes |
| ignition\_gen | n/a | `list(string)` | <pre>[<br>  "sh",<br>  "-c",<br>  "rm -rf *.ign && ../../../tools/generate-configs.sh"<br>]</pre> | no |
| master\_nodes | n/a | <pre>object({<br>    disk_size    = number<br>    memory       = number<br>    num_cpu      = number<br>    machine_cidr = string<br>    netmask      = string<br>    gateway      = string<br>    network      = string<br>    ips          = list(string)<br>  })</pre> | `null` | no |
| ntp\_servers | n/a | `list(string)` | n/a | yes |
| vc\_cluster | n/a | `string` | n/a | yes |
| vc\_dc | n/a | `string` | n/a | yes |
| vc\_ds | n/a | `string` | n/a | yes |
| vm\_folder | n/a | `string` | n/a | yes |
| worker\_nodes | n/a | <pre>list(object({<br>    disk_size    = number<br>    memory       = number<br>    num_cpu      = number<br>    slug         = string<br>    machine_cidr = string<br>    netmask      = string<br>    gateway      = string<br>    network      = string<br>    attachments  = list(list(map(string)))<br>    ips          = list(string)<br>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| api\_endpoint | n/a |
| bootstrap\_kubeconfig | n/a |
| cluster | n/a |
| ingress\_domain | n/a |
| kubeadmin\_password | n/a |
| openssh\_private\_key | terraform output -raw openssh\_private\_key |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
