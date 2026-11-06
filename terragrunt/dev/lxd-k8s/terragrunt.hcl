# terragrunt/dev/lxd-network/terragrunt.hcl
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
  "root-k8s" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/root-k8s"
    }
  "data-k8s" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/data-k8s"
    }
  }

  instances = {
    master-01 = {
      type         = "virtual-machine"
      root_disk_size = "20GiB"
      ipv4_address = "172.10.10.11"
      cpu          = "2"
      memory       = "4GiB"
      volumes = {}
    
    }
    worker-01 = {
      root_disk_size = "30GiB"
      ipv4_address = "172.10.10.21"
      cpu          = "2"
      memory       = "4GiB"
      volumes = {
        data = {
          size   = "30GiB"
          pool = "data-k8s"
        }
      }
    }
    worker-02 = {
      root_disk_size = "30GiB"
      ipv4_address = "172.10.10.22"
      cpu          = "2"
      memory       = "4GiB"
      volumes = {
        data = {
          size   = "30GiB"
          pool = "data-k8s"
        }
      }
    }
    worker-03 = {
      root_disk_size = "30GiB"
      ipv4_address = "172.10.10.23"
      cpu          = "2"
      memory       = "4GiB"
      volumes = {
        data = {
          size   = "30GiB"
          pool = "data-k8s"
        }
      }
    }
  }
}