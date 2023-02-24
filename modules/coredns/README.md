# modules/coredns

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bootstrap\_ip | n/a | `string` | n/a | yes |
| cluster\_domain | n/a | `string` | n/a | yes |
| cluster\_slug | n/a | `string` | n/a | yes |
| coredns\_ip | n/a | `string` | n/a | yes |
| loadbalancer\_ip | n/a | `string` | n/a | yes |
| master\_ips | n/a | `list(string)` | n/a | yes |
| ssh\_key\_file | n/a | `list(string)` | n/a | yes |
| worker\_ips | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ignition | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## TODO
- Explain this thing a bit