# Kubernetes Cluster Configuration Setup Guide

This guide provides detailed instructions for setting up and using the Ansible automation for Kubernetes cluster configuration using AWS EC2 instances.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Installation](#installation)
4. [Project Structure](#project-structure)
5. [Configuration](#configuration)
6. [Usage](#usage)
7. [Troubleshooting](#troubleshooting)
8. [Security Considerations](#security-considerations)

## Prerequisites

### AWS Requirements
- AWS Account with appropriate permissions
- AWS CLI configured with credentials
- Key pair for EC2 instances
- Security groups configured for:
  - SSH access (port 22)
  - Kubernetes API server (port 6443)
  - etcd server client API (port 2379)
  - etcd peer communication (port 2380)
  - Kubelet API (port 10250)
  - kube-scheduler (port 10259)
  - kube-controller-manager (port 10257)
  - NodePort Services (ports 30000-32767)

### Control Node Requirements
- EC2 instance (t2.medium or larger recommended)
- Ubuntu 20.04 LTS or later
- Ansible 2.9 or later
- Python 3.6 or later
- SSH client
- Git

### Target Node Requirements
- EC2 instances (t2.medium or larger recommended)
- Ubuntu 20.04 LTS or later
- SSH server
- Python 3.6 or later
- Sudo privileges
- Minimum 2GB RAM
- Minimum 2 CPU cores
- 20GB free disk space

## Initial Setup

### 1. Launch EC2 Instances

1. **Launch Control Node**
   - Instance type: t2.medium or larger
   - AMI: Ubuntu Server 20.04 LTS
   - Security group: Allow SSH (port 22)
   - Key pair: Use your existing key pair or create a new one
   - Tag: Name=ansible-control

2. **Launch Master Nodes**
   - Number of instances: 3 (for high availability)
   - Instance type: t2.medium or larger
   - AMI: Ubuntu Server 20.04 LTS
   - Security group: Allow required Kubernetes ports
   - Key pair: Same as control node
   - Tags: Name=master-1, Name=master-2, Name=master-3

3. **Launch Worker Nodes**
   - Number of instances: 2 or more
   - Instance type: t2.medium or larger
   - AMI: Ubuntu Server 20.04 LTS
   - Security group: Allow required Kubernetes ports
   - Key pair: Same as control node
   - Tags: Name=worker-1, Name=worker-2

### 2. Set Up SSH Access

1. **Connect to Control Node**
   ```bash
   # From your local machine
   ssh -i /path/to/your-key.pem ubuntu@control-node-public-ip
   ```

2. **Generate SSH Key Pair on Control Node**
   ```bash
   # On the control node
   ssh-keygen -t rsa -b 4096
   ```
   
   When prompted:
   - Enter file name: Press Enter to use the default location (`~/.ssh/id_rsa`)
   - Enter passphrase: Press Enter for no passphrase (since this is a server)
   - Confirm passphrase: Press Enter

3. **Copy Public Key to Target Nodes**
   
   For each target node (master and worker nodes):

   ```bash
   # Method 1: Using ssh-copy-id
   ssh-copy-id -i ~/.ssh/id_rsa.pub ubuntu@target-node-private-ip
   
   # You'll be prompted for the target node's password
   # After successful copy, test the connection:
   ssh ubuntu@target-node-private-ip
   ```

   If `ssh-copy-id` is not available:

   ```bash
   # Method 2: Manual copy
   # 1. Display your public key
   cat ~/.ssh/id_rsa.pub
   
   # 2. SSH into the target node
   ssh -i /path/to/your-key.pem ubuntu@target-node-public-ip
   
   # 3. On the target node, append the public key
   mkdir -p ~/.ssh
   echo "PASTE_YOUR_PUBLIC_KEY_HERE" >> ~/.ssh/authorized_keys
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

4. **Test SSH Connection**
   ```bash
   # Test connection to each node using private IPs
   ssh ubuntu@master-1-private-ip
   ssh ubuntu@master-2-private-ip
   ssh ubuntu@master-3-private-ip
   ssh ubuntu@worker-1-private-ip
   ssh ubuntu@worker-2-private-ip
   ```

### 3. Prepare Target Nodes

1. **Update System Packages**
   ```bash
   # On each target node
   sudo apt update && sudo apt upgrade -y
   ```

2. **Install Required Base Packages**
   ```bash
   # On each target node
   sudo apt install -y python3 python3-pip openssh-server
   ```

3. **Enable SSH Service**
   ```bash
   # On each target node
   sudo systemctl enable ssh
   sudo systemctl start ssh
   ```

4. **Configure Hostnames**
   ```bash
   # On master-1
   sudo hostnamectl set-hostname master-1
   
   # On master-2
   sudo hostnamectl set-hostname master-2
   
   # On master-3
   sudo hostnamectl set-hostname master-3
   
   # On worker-1
   sudo hostnamectl set-hostname worker-1
   
   # On worker-2
   sudo hostnamectl set-hostname worker-2
   ```

## Installation

### 1. Clone the Repository
```bash
# On the control node
git clone <repository-url>
cd kubernetes-ansible
```

### 2. Install Ansible
```bash
# On the control node
sudo apt update
sudo apt install -y ansible python3-pip
```

### 3. Install Required Python Packages
```bash
# On the control node
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