# terrugrunt/stack/lxd-network/main.tf
# Create network
locals {
    name       = "lxd-${var.project}-${var.environment}"
    dns_domain = "cluster.${var.environment}.int.devhomelab.site"
    dns_search = "cluster.${var.environment}.int.devhomelab.site"
}

variable "project" {
  type        = string
  default     = "network"
  description = "Project name used in network name and DNS domain"
}

variable "network" {
  description = "Network configurations"
  type = object({
    ipv4_address = string
    ipv6_address = string
    nat          = bool
    dhcp         = bool
    raw_dnsmasq  = optional(string, "")

  })
}

variable "environment" {
  type = string
  description = "Variable for environment"
}

module "network" {
  source = "git::https://github.com/vladoz77/lxd-network.git?ref=v1.0.0"
  network = merge(var.network, 
  {
    name = local.name
    dns_domain = local.dns_domain
    dns_search = local.dns_search
  }
  )

}

output "network_name" {
  value = module.network.network_name
}