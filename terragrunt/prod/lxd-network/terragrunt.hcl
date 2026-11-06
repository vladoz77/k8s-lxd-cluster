# terragrunt/dev/lxd-network/terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../stack/lxd-network"
}

inputs = {
  project = "k8s"
  network = {
    ipv4_address = "192.168.1.254/24"
    ipv6_address = "none"
    nat = true
    dhcp = true
    raw_dnsmasq = <<-EOF
        server=10.10.0.254
        dhcp-option=6,10.10.0.254
    EOF
  }
}