terraform {
  required_version = ">= 1.5.0"
  
  # Local state for demonstration, but structured for remote backend
  backend "local" {
    path = "terraform.tfstate"
  }
}

variable "target_provider" {
  description = "Chosen cloud provider (aws, contabo, hetzner)"
  type        = string
  default     = "hetzner"
}

variable "vps_name" {
  type    = string
  default = "prod-server-01"
}

variable "admin_username" {
  type    = string
  default = "adminuser"
}

variable "ssh_public_key" {
  type = string
}

# --- Cloud-Init Render ---
locals {
  user_data = templatefile("${path.module}/../../modules/bootstrap/cloud-init.yaml.tpl", {
    admin_username = var.admin_username
    ssh_public_key = var.ssh_public_key
  })
}

# --- Compute Cluster ---
module "compute" {
  source          = "../../modules/compute"
  target_provider = var.target_provider
  vps_name        = var.vps_name
  ssh_public_key  = var.ssh_public_key
  user_data       = local.user_data
}

output "server_ip" {
  value = module.compute.instance_ip
}
