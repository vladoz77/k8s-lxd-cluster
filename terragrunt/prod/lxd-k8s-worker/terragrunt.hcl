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
  "root-k8s-worker-prod" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/root-k8s-worker-prod"
    }
  "data-k8s-prod" = {
    pool_driver = "dir"
    pool_source = "/lxd-pools/data-k8s-prod"
    }
  }

  instances = {
    worker-01 = {
      root_disk_size = "30GiB"
      root_disk_pool = "root-k8s-worker-prod"
      ipv4_address = "192.168.1.21"
      cpu          = "2"
      memory       = "2GiB"
      volumes = {
        data = {
          size   = "30GiB"
          pool = "data-k8s-prod"
        }
      }
    }
    worker-02 = {
      root_disk_size = "30GiB"
      root_disk_pool = "root-k8s-worker-prod"
      ipv4_address = "192.168.1.22"
      cpu          = "2"
      memory       = "2GiB"
      volumes = {
        data = {
          size   = "30GiB"
          pool = "data-k8s-prod"
        }
      }
    }
  }
}