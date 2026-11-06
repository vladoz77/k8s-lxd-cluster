# terragrunt/stack/lxd-profile/main.tf
# Create LXD profile
locals {
  lxd_profile_name = "${var.lxd_profile_name}-${var.environment}"
}

variable "lxd_profile_name" {
  type    = string
}

variable "environment" {
  type = string
}

resource "lxd_profile" "vm" {
  name = local.lxd_profile_name
}

output "name" {
  value = lxd_profile.vm.name
}