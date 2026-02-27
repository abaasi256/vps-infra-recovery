terraform {
  required_providers {
    contabo = {
      source  = "contabo/contabo"
      version = "~> 0.1"
    }
  }
}

variable "vps_name" { type = string }
variable "region" { type = string; default = "de" }
variable "product_id" { type = string; default = "vps-s-ssd" }
variable "image_id" { type = string; default = "ubuntu-22.04" }
variable "ssh_public_key" { type = string }
variable "user_data" { type = string }

resource "contabo_instance" "vps" {
  display_name = var.vps_name
  region       = var.region
  product_id   = var.product_id
  image_id     = var.image_id
  ssh_keys     = [var.ssh_public_key]
  user_data    = var.user_data
}

output "instance_ip" {
  value = contabo_instance.vps.ip_address
}
