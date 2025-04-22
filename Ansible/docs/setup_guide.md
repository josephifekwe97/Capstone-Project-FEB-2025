# Kubernetes Cluster Configuration Setup Guide

This guide provides detailed instructions for setting up and using the Ansible automation for Kubernetes cluster configuration.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Project Structure](#project-structure)
4. [Configuration](#configuration)
5. [Usage](#usage)
6. [Troubleshooting](#troubleshooting)
7. [Security Considerations](#security-considerations)

## Prerequisites

### Control Node Requirements
- Ansible 2.9 or later
- Python 3.6 or later
- SSH client
- Git

### Target Node Requirements
- Ubuntu 20.04 LTS or later (recommended)
- CentOS 8 or later (alternative)
- SSH server
- Python 3.6 or later
- Sudo privileges
- Minimum 2GB RAM
- Minimum 2 CPU cores
- 20GB free disk space

## Installation

### 1. Clone the Repository
```bash
git clone <repository-url>
cd kubernetes-ansible
```

### 2. Install Ansible
#### On Ubuntu/Debian:
```bash
sudo apt update
sudo apt install -y ansible python3-pip
```

#### On CentOS/RHEL:
```bash
sudo yum install -y epel-release
sudo yum install -y ansible python3-pip
```

### 3. Install Required Python Packages
```bash
pip3 install -r requirements.txt
```

## Project Structure

```
.
├── ansible.cfg           # Ansible configuration
├── inventory/           # Inventory files
│   ├── hosts           # Main inventory file
│   └── group_vars/     # Group variables
├── roles/              # Ansible roles
│   ├── common/         # Common system configuration
│   ├── security/       # Security hardening
│   ├── kubernetes/     # Kubernetes specific setup
│   └── packages/       # Package management
├── playbooks/          # Main playbooks
│   ├── setup.yml       # Main setup playbook
│   └── security.yml    # Security hardening playbook
└── scripts/            # Helper scripts
    └── run.sh          # Main execution script
```

## Configuration

### 1. Configure Inventory

Edit `inventory/hosts` to add your nodes:

```ini
[control_plane]
master1 ansible_host=192.168.1.10
master2 ansible_host=192.168.1.11
master3 ansible_host=192.168.1.12

[worker_nodes]
worker1 ansible_host=192.168.1.20
worker2 ansible_host=192.168.1.21
worker3 ansible_host=192.168.1.22
```

### 2. Configure Group Variables

Edit `inventory/group_vars/all.yml` to customize settings:

```yaml
# System settings
timezone: UTC
system_locale: en_US.UTF-8

# Kubernetes settings
kubernetes_version: "1.28.0"
container_runtime: docker
pod_cidr: "10.244.0.0/16"
service_cidr: "10.96.0.0/12"
```

### 3. Configure SSH Access

1. Generate SSH key pair on control node:
```bash
ssh-keygen -t rsa -b 4096
```

2. Copy public key to target nodes:
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub user@target-node
```

## Usage

### 1. Make the Script Executable
```bash
chmod +x scripts/run.sh
```

### 2. Run the Setup Script
```bash
./scripts/run.sh
```

The script provides a menu with the following options:
1. Full Setup (All roles)
2. Security Hardening Only
3. Check System Requirements
4. Exit

### 3. Verify Installation

After completion, verify the setup:

```bash
# On control plane nodes
kubectl get nodes

# Check system services
systemctl status docker
systemctl status kubelet
```

## Troubleshooting

### Common Issues

1. **SSH Connection Issues**
   - Verify SSH keys are properly set up
   - Check firewall rules
   - Ensure SSH service is running

2. **Package Installation Failures**
   - Check internet connectivity
   - Verify repository configurations
   - Check disk space

3. **Kubernetes Service Issues**
   - Check system logs: `journalctl -u kubelet`
   - Verify network connectivity
   - Check resource availability

### Log Files
- Ansible logs: `ansible.log`
- System logs: `/var/log/syslog`
- Kubernetes logs: `/var/log/pods/`

## Security Considerations

### 1. SSH Security
- Password authentication is disabled
- Root login is disabled
- SSH key authentication is required

### 2. Firewall Configuration
- Only necessary ports are open
- Default deny policy
- Rate limiting enabled

### 3. System Hardening
- Regular security updates
- Fail2ban protection
- Audit logging enabled
- Secure file permissions

### 4. Kubernetes Security
- RBAC enabled
- Network policies
- Pod security policies
- TLS encryption

## Best Practices

1. **Regular Updates**
   - Keep Ansible updated
   - Apply security patches
   - Update Kubernetes components

2. **Backup**
   - Regular backup of etcd data
   - Backup of configuration files
   - Document all customizations

3. **Monitoring**
   - Set up monitoring tools
   - Configure alerts
   - Regular security audits

4. **Documentation**
   - Keep inventory updated
   - Document all changes
   - Maintain runbooks

## Support

For issues and support:
1. Check the troubleshooting section
2. Review system logs
3. Consult the documentation
4. Contact the support team

## License

This project is licensed under the MIT License - see the LICENSE file for details. 