# modules/haproxy

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| api\_backend\_addresses | n/a | `list(string)` | n/a | yes |
| env | Error: initializing source docker://quay.io/openshift/origin-haproxy-router:latest: pinging container registry quay.io: Get "https://quay.io/v2/": tls: server chose an unconfigured cipher suite | `map(string)` | `{}` | no |
| ingress | n/a | `list(string)` | `[]` | no |
| lb\_ip\_address | n/a | `string` | n/a | yes |
| ssh\_key\_file | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ignition | n/a |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## TODO
- Explain this thing a bit