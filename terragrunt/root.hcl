remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = "vladis-terraform-state"
    key    = "lxd/k8s-infrastructure/${path_relative_to_include()}.tfstate"
    region = "ru-central1"
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    terraform {
      required_version = ">= 1.9.0"
      required_providers {
        lxd = {
          source  = "terraform-lxd/lxd"
          version = ">= 3.0.1"
        }
      }
    }
  EOF
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    variable "lxd_server_address"          { type = string }
    variable "lxd_server_cert_fingerprint" { type = string }

    provider "lxd" {
      remote {
        name                           = "lxd-server-rocky"
        address                        = var.lxd_server_address
        client_certificate_file        = pathexpand("~/snap/lxd/common/config/client.crt")
        client_key_file                = pathexpand("~/snap/lxd/common/config/client.key")
        server_certificate_fingerprint = var.lxd_server_cert_fingerprint
      }
    }
  EOF
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

# Общие для всех окружений значения (child может их переопределить)
inputs = {
  lxd_image_os                = "rocky-9-cloud"
  lxd_server_address          = "https://127.0.0.1:7443"
  lxd_server_cert_fingerprint = "44c56118b4bc26e1ab7a5961b749665fd6157a2134d9279af660242cb2156d80"
  environment = local.env.locals.environment
}
