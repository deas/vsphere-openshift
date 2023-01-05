variable "lb_ip_address" {
  type = string
}

variable "api_backend_addresses" {
  type = list(string)
}

variable "ingress" {
  type    = list(string)
  default = []
}

variable "ssh_key_file" {
  type = list(string)
}

# Error: initializing source docker://quay.io/openshift/origin-haproxy-router:latest: pinging container registry quay.io: Get "https://quay.io/v2/": tls: server chose an unconfigured cipher suite
variable "env" {
  type    = map(string)
  default = {}
}