# Kubernetes Cluster Configuration with Ansible

This project provides Ansible automation for setting up and managing Kubernetes clusters across various environments, including cloud providers (AWS, GCP, Azure) and local machines.

## Features

- Automated Kubernetes cluster deployment
- Support for both manual and automated SSH setup
- Comprehensive security hardening
- Flexible configuration options
- Detailed logging and monitoring
- Backup and restore capabilities
- Health checks and validation
- Parallel processing for faster setup
- Cloud-agnostic design
- Local machine support

## Prerequisites

### General Requirements
- Control Node (can be local machine or cloud instance)
- Target Nodes (can be cloud instances or local machines)
- SSH access between nodes
- Python 3.6 or later
- Ansible 2.9 or later
- Git

### Cloud Provider Requirements
If using cloud providers, ensure:
- Appropriate account permissions
- CLI tools configured (AWS CLI, gcloud, az)
- Key pairs or authentication methods
- Security groups/firewalls configured for:
  - SSH access (port 22)
  - Kubernetes API server (port 6443)
  - etcd server client API (port 2379)
  - etcd peer communication (port 2380)
  - Kubelet API (port 10250)
  - kube-scheduler (port 10259)
  - kube-controller-manager (port 10257)
  - NodePort Services (ports 30000-32767)

### Hardware Requirements
- Control Node:
  - 2 CPU cores minimum
  - 4GB RAM minimum
  - 20GB storage minimum
- Master Nodes:
  - 2 CPU cores minimum
  - 4GB RAM minimum
  - 20GB storage minimum
- Worker Nodes:
  - 2 CPU cores minimum
  - 4GB RAM minimum
  - 20GB storage minimum

## Quick Start

### 1. Prepare Your Environment

#### Cloud Setup
- Launch instances for control and target nodes
- Configure security groups/firewalls
- Set up key pairs or authentication methods

#### Local Setup
- Ensure machines meet hardware requirements
- Configure network connectivity
- Set up SSH access between machines

### 2. Set Up SSH Access

You have two options for setting up SSH access:

#### Option 1: Manual Setup
```bash
# Connect to control node
ssh <user>@<control-node-ip>

# Generate SSH key pair
ssh-keygen -t rsa -b 4096

# Copy public key to target nodes
ssh-copy-id <user>@<target-node-ip>
```

#### Option 2: Automated Setup (Recommended)
```bash
# Copy and edit configuration
cp scripts/config.yaml.example scripts/config.yaml
nano scripts/config.yaml

# Make script executable
chmod +x scripts/setup_ssh.sh

# Run the script
./scripts/setup_ssh.sh
```

The automated script provides:
- Interactive menu interface
- Parallel processing
- Health checks
- Backup and restore
- Comprehensive logging

### 3. Clone and Configure
```bash
git clone <repository-url>
cd kubernetes-ansible

# Configure inventory
nano inventory/hosts

# Configure variables
nano inventory/group_vars/all.yml
```

### 4. Run Setup
```bash
# Make the script executable
chmod +x scripts/run.sh

# Run the setup
./scripts/run.sh
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
├── scripts/            # Helper scripts
│   ├── setup_ssh.sh    # SSH setup automation
│   ├── run.sh          # Main execution script
│   └── config.yaml     # SSH setup configuration
└── docs/               # Documentation
    ├── setup_guide.md  # Detailed setup instructions
    └── troubleshooting.md # Troubleshooting guide
```

## Configuration

### Inventory Configuration
Edit `inventory/hosts` to add your nodes:

```ini
[control_plane]
master1 ansible_host=192.168.1.10
master2 ansible_host=192.168.1.11
master3 ansible_host=192.168.1.12

[worker_nodes]
worker1 ansible_host=192.168.1.20
worker2 ansible_host=192.168.1.21
```

### Variables Configuration
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

## Documentation

- [Setup Guide](docs/setup_guide.md) - Detailed instructions for manual and automated setup
- [Troubleshooting Guide](docs/troubleshooting.md) - Common issues and solutions

## Security Features

- SSH key authentication only
- Disabled password authentication
- Disabled root login
- Firewall configuration
- Regular security updates
- Fail2ban protection
- Audit logging
- RBAC enabled
- Network policies
- TLS encryption

## Support

For issues and support:
1. Check the [troubleshooting guide](docs/troubleshooting.md)
2. Review system logs
3. Consult the documentation
4. Contact the support team

## License

This project is licensed under the MIT License - see the LICENSE file for details. 