# 🛡️ Security Architecture & Best Practices

This document outlines the security model and hardening procedures implemented in the **VPS Infra Recovery** platform.

## 1. Zero-Leak Secret Strategy

We implement a multi-layered approach to prevent sensitive information from entering the version control system:

- **Git Isolation**: `.gitignore` is configured to block `.env`, `.tfstate`, `*.pem`, `*.key`, and `secrets.tfvars`.
- **Credential Templates**: `.env.example` provides a blueprint for required secrets without containing live data.
- **Variable Injection**: Terraform variables are injected via environment variables (`TF_VAR_...`) to keep sensitive values in system memory rather than on disk.
- **Provider Credential Isolation**: Each cloud provider (AWS, Hetzner, Contabo) uses its own dedicated authentication mechanism, preventing credential "blast radius" expansion.

## 2. Infrastructure Hardening (Cloud-Init)

During the initial provisioning phase, the system automatically executes a hardening sequence:

### Identity & Access

- **Non-Root Administrator**: A dedicated admin user is created immediately.
- **SSH-Only Access**: Password authentication is disabled in favor of mandatory SSH key-based authentication.
- **Sudo Restrictions**: The admin user is granted `NOPASSWD` sudo rights solely for automated provisioning, which can be further restricted post-deployment.

### Host Protection

- **Fail2ban**: Automatically installed and configured to protect against brute-force SSH attacks.
- **Automatic Updates**: Configured to poll for and install security patches without manual intervention.
- **Package Integrity**: All repositories are added via GPG-signed keys.

## 3. Network Security (Layer 4)

We implement a "Default Deny" posture using **UFW (Uncomplicated Firewall)**:

| Port | Protocol | Purpose | Access |
| :--- | :--- | :--- | :--- |
| 22 | TCP | SSH Management | Restricted (Admin) |
| 80 | TCP | HTTP Traffic | Public |
| 443 | TCP | HTTPS (SSL) | Public |
| * | * | All Other | **Block** |

## 4. Container & Runtime Security

- **Resource Limits**: Docker Compose configurations include memory and CPU limits to prevent "noisy neighbor" or DoS attacks from compromised containers.
- **Network Isolation**: Applications are deployed on internal Docker bridge networks, exposing only necessary ports via the reverse proxy.
- **Restart Policies**: Configured to ensure high availability while limiting thermal runaways in failing services.

## 5. Backup & Recovery Security

- **Artifact Integrity**: The `capture.sh` script produces a compressed tarball containing metadata for integrity verification.
- **Off-site Storage**: Users are encouraged to move backup artifacts (`infra-export-*.tar.gz`) to an encrypted, off-site location (e.g., AWS S3 with KMS).
- **Environment Parity**: The restore engine ensures that the security posture of the original server is exactly replicated on the target clone.

---

## Reporting a Vulnerability

If you discover a security vulnerability within this platform, please do **not** open a public issue. Instead, report it directly to the maintainer:

- **Contact**: `abaasi256` via GitHub DM or specified security email.
- **Encryption**: Please encrypt your message if sensitive details are included.

We aim to acknowledge every report within 24 hours.
