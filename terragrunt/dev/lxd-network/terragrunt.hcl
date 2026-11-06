# terragrunt/dev/lxd-network/terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../stack/lxd-network"
}

inputs = {
  network = {
    name = "lxdbr-dev"
    ipv4_address = "172.10.10.1/24"
    ipv6_address = "none"
    nat = true
    dhcp = true
    dns_domain = "cluster.int.devhomelab.site"
    dns_search = "cluster.int.devhomelab.site"
    raw_dnsmasq = <<-EOF
        server=10.10.0.254
        dhcp-option=6,10.10.0.254
    EOF
  }
}