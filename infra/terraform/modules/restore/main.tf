# This module handles the deployment of the restoration engine scripts to the target host.

variable "host_ip" { type = string }
variable "admin_username" { type = string }
variable "ssh_private_key_path" { type = string }

resource "null_resource" "restore_engine" {
  connection {
    type        = "ssh"
    user        = var.admin_username
    private_key = file(var.ssh_private_key_path)
    host        = var.host_ip
  }

  provisioner "file" {
    source      = "${path.module}/../../../../backup/scripts/restore.sh"
    destination = "/opt/infra-recovery/restore.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /opt/infra-recovery/restore.sh"
    ]
  }
}
