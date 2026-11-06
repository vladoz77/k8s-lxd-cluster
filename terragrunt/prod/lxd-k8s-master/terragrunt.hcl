# terragrunt/prod/lxd-k8s-master/terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../stack/lxd-instance"
}

dependency "profile" {
  config_path = "../lxd-profile"

  mock_outputs                            = { name = "mock" }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

dependency "network" {
  config_path = "../lxd-network"

  mock_outputs                            = { network_name = "mock" }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  profile_name = dependency.profile.outputs.name
  network_name = dependency.network.outputs.network_name

  pools = {
  "root-k8s-master-prod" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/root-k8s-master-prod"
    }
  }

  instances = {
    master-01 = {
      type         = "virtual-machine"
      root_disk_size = "20GiB"
      root_disk_pool = "root-k8s-master-prod"
      ipv4_address = "192.168.1.11"
      cpu          = "2"
      memory       = "2GiB"
      volumes = {}
    }
    master-02 = {
      type         = "virtual-machine"
      root_disk_size = "20GiB"
      root_disk_pool = "root-k8s-master-prod"
      ipv4_address = "192.168.1.12"
      cpu          = "2"
      memory       = "2GiB"
      volumes = {}
    
    }
    master-03 = {
      type         = "virtual-machine"
      root_disk_size = "20GiB"
      root_disk_pool = "root-k8s-master-prod"
      ipv4_address = "192.168.1.13"
      cpu          = "2"
      memory       = "2GiB"
      volumes = {}
    }
  }
}