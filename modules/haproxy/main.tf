data "ignition_systemd_unit" "haproxy" {
  name = "haproxy.service"
  content = templatefile("${path.module}/files/haproxy.service.tmpl", {
    env = var.env
  })
}

data "ignition_file" "proxy_env" {
  count = length(keys(var.env)) > 0 ? 1 : 0
  path  = "/etc/profile.d/proxy.sh"
  mode  = "422"
  content {
    content = templatefile("${path.module}/files/env.sh.tmpl", {
      env = var.env
    })
  }
}

data "ignition_file" "haproxy" {
  path = "/etc/haproxy/haproxy.conf"
  mode = "420" // 0644
  content {
    content = templatefile("${path.module}/files/haproxy.tmpl", {
      lb_ip_address = var.lb_ip_address,
      api           = var.api_backend_addresses,
      ingress       = var.ingress
    })
  }
}

data "ignition_user" "core" {
  name                = "core"
  ssh_authorized_keys = var.ssh_key_file
}

# proxy object introduced with spec 3.1 not covered by 2.1.3 provider
data "ignition_config" "lb" {
  users = [data.ignition_user.core.rendered]
  files = concat([
    data.ignition_file.haproxy.rendered],
    try([data.ignition_file.proxy_env[0].rendered], [])
  )
  systemd = [data.ignition_systemd_unit.haproxy.rendered /*,
   # systemctl list-unit-files --type=service
   jsonencode({
     "name" = "vmtoolsd.service"
     "enabled" = true})
     */
  ]
}
