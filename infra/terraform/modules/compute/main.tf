variable "target_provider" { type = string }
variable "vps_name" { type = string }
variable "ssh_public_key" { type = string }
variable "user_data" { type = string }

module "aws_compute" {
  count          = var.target_provider == "aws" ? 1 : 0
  source         = "../../providers/aws"
  vps_name       = var.vps_name
  ssh_public_key = var.ssh_public_key
  user_data      = var.user_data
}

module "hetzner_compute" {
  count          = var.target_provider == "hetzner" ? 1 : 0
  source         = "../../providers/hetzner"
  vps_name       = var.vps_name
  ssh_public_key = var.ssh_public_key
  user_data      = var.user_data
}

module "contabo_compute" {
  count          = var.target_provider == "contabo" ? 1 : 0
  source         = "../../providers/contabo"
  vps_name       = var.vps_name
  ssh_public_key = var.ssh_public_key
  user_data      = var.user_data
}

output "instance_ip" {
  value = (
    var.target_provider == "aws" ? module.aws_compute[0].instance_ip :
    var.target_provider == "hetzner" ? module.hetzner_compute[0].instance_ip :
    var.target_provider == "contabo" ? module.contabo_compute[0].instance_ip : ""
  )
}
