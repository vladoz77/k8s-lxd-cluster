# terragrunt/dev/lxd-profile/terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../stack/lxd-profile"
}

inputs = {
    lxd_profile_name = "k8s-profile"
}