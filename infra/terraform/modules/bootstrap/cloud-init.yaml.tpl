#cloud-config
users:
  - name: ${admin_username}
    groups: sudo, docker
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ${ssh_public_key}

package_update: true
package_upgrade: true

packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg
  - lsb-release
  - fail2ban
  - ufw
  - git
  - jq

runcmd:
  # Security Hardening
  - ufw default deny incoming
  - ufw default allow outgoing
  - ufw allow ssh
  - ufw allow http
  - ufw allow https
  - ufw --force enable
  
  # Fail2ban basic config
  - systemctl enable fail2ban
  - systemctl start fail2ban

  # Install Docker
  - mkdir -p /etc/apt/keyrings
  - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  - apt-get update
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  
  # Enable Docker
  - systemctl enable docker
  - systemctl start docker

  # Restore Script Placeholder / Setup
  - mkdir -p /opt/infra-recovery/backups
  - chown -R ${admin_username}:${admin_username} /opt/infra-recovery

  # Final cleanup
  - apt-get autoremove -y
  - apt-get clean
