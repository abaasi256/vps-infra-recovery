# Common security policies and firewall rules abstraction.

variable "allowed_ssh_ips" {
  type    = list(string)
  default = ["0.0.0.0/0"] # Hardened defaults would restrict this
}

output "ufw_base_commands" {
  value = [
    "ufw default deny incoming",
    "ufw default allow outgoing",
    "ufw allow ssh",
    "ufw allow http",
    "ufw allow https"
  ]
}
