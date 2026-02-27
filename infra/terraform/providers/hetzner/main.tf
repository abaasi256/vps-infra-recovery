terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
}

variable "vps_name" { type = string }
variable "region" { type = string; default = "fsn1" }
variable "server_type" { type = string; default = "cx21" }
variable "image" { type = string; default = "ubuntu-22.04" }
variable "ssh_public_key" { type = string }
variable "user_data" { type = string }

resource "hcloud_ssh_key" "default" {
  name       = "${var.vps_name}-key"
  public_key = var.ssh_public_key
}

resource "hcloud_server" "vps" {
  name        = var.vps_name
  server_type = var.server_type
  image       = var.image
  location    = var.region
  ssh_keys    = [hcloud_ssh_key.default.id]
  user_data    = var.user_data
}

output "instance_ip" {
  value = hcloud_server.vps.ipv4_address
}
