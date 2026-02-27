terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "vps_name" { type = string }
variable "region" { type = string; default = "us-east-1" }
variable "instance_type" { type = string; default = "t3.medium" }
variable "ami_id" { type = string; default = "ami-0c7217cdde317cfec" } # Ubuntu 22.04 LTS
variable "ssh_public_key" { type = string }
variable "user_data" { type = string }

resource "aws_key_pair" "deployer" {
  key_name   = "${var.vps_name}-key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "vps" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name
  user_data     = var.user_data

  tags = {
    Name = var.vps_name
  }
}

output "instance_ip" {
  value = aws_instance.vps.public_ip
}
