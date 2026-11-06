# terragrunt/stack/lxd-instance/main.tf
# Create storage pools
resource "lxd_storage_pool" "pools" {
  for_each = var.pools

  name   = each.key
  driver = each.value.pool_driver

  config = {
    source = each.value.pool_source
  }
}

# Create instance
module "instance" {
  for_each = var.instances

  source = "git::https://github.com/vladoz77/lxd-instance.git?ref=v1.0.0"

  network_name     = var.network_name
  profiles         = [var.profile_name]
  volumes          = each.value.volumes
  instance = {
    root_disk_size   = each.value.root_disk_size
    root_disk_pool = try(
      lxd_storage_pool.pools[each.value.root_disk_pool].name,
      each.value.root_disk_pool
    )
    name             = "k8s-${each.key}"
    image            = var.lxd_image_os
    ipv4_address     = each.value.ipv4_address
    cpu              = each.value.cpu
    memory           = each.value.memory
    cloud_init       = file("${path.module}/cloud-init.yaml")
  }
}
# variables for the module
variable "network_name" { type = string }
variable "profile_name" { type = string }
variable "lxd_image_os" { type = string }

variable "pools" {
  description = "Map of storage pools to create"
  type = map(object({
    pool_source = string
    pool_driver = string
  }))
  default = {}
}

variable "instances" {
  description = "Map of instances to create"
  type = map(object({
    ipv4_address   = string
    cpu            = number
    memory         = string
    root_disk_size = string
    root_disk_pool = string
    volumes = map(object({
      size = string
      pool = string
    }))
  }))
}

# outputs for the module
output "instance" {
  value = { for key, value in module.instance : key => {
    name    = value.instance_name
    ipv4    = value.ipv4_address
    volumes = value.volumes
  } }
}

output "storage_pools" {
  value = { for key, pool in lxd_storage_pool.pools : key => {
    name   = pool.name
    driver = pool.driver
    source = pool.config.source
  } }
}