# Ansible Multi-Node Setup Guide

This guide provides detailed instructions for setting up Ansible across multiple nodes, including SSH automation and node configuration.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [SSH Setup](#ssh-setup)
4. [Ansible Configuration](#ansible-configuration)
5. [Node Setup](#node-setup)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- Linux-based operating system
- Python 3.x
- SSH client
- `yq` (YAML processor)

### Network Requirements
- SSH access to all nodes
- Network connectivity between nodes
- Proper firewall configuration

### Directory Structure
```bash
.
├── ansible.cfg
├── inventory/
├── playbooks/
├── roles/
├── scripts/
│   ├── setup_ssh.sh
│   └── config.yml
└── docs/
```

## Installation

1. **Install Python Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

2. **Install System Packages**
   ```bash
   # For Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install -y ansible ssh yq

   # For CentOS/RHEL
   sudo yum install -y ansible openssh-clients yq
   ```

3. **Verify Installation**
   ```bash
   ansible --version
   ssh -V
   yq --version
   ```

## SSH Setup

1. **Configure SSH Access**
   - Update `scripts/config.yml` with node information
   - Run the SSH setup script:
     ```bash
     ./scripts/setup_ssh.sh
     ```

2. **SSH Setup Options**
   - Setup all nodes
   - Setup specific node
   - Show failed nodes
   - View logs
   - Show node status
   - Monitor nodes
   - Cleanup temporary files

3. **Verify SSH Access**
   ```bash
   # Test SSH to each node
   ssh user@node-ip
   ```

## Ansible Configuration

1. **Configure ansible.cfg**
   ```ini
   [defaults]
   inventory = inventory/hosts
   remote_user = your-username
   private_key_file = ~/.ssh/id_rsa
   host_key_checking = False
   ```

2. **Set Up Inventory**
   Create `inventory/hosts`:
   ```ini
   [control]
   control ansible_host=your-control-ip

   [masters]
   master-1 ansible_host=your-master-ip
   master-2 ansible_host=your-master-ip

   [workers]
   worker-1 ansible_host=your-worker-ip
   worker-2 ansible_host=your-worker-ip
   ```

3. **Create Basic Playbook**
   Create `playbooks/setup.yml`:
   ```yaml
   ---
   - name: Initial Setup
     hosts: all
     become: yes
     tasks:
       - name: Update package cache
         apt:
           update_cache: yes
         when: ansible_os_family == "Debian"
   ```

## Node Setup

1. **Control Node**
   ```bash
   # Install Ansible
   sudo apt-get install -y ansible

   # Verify installation
   ansible --version
   ```

2. **Master Nodes**
   ```bash
   # Run setup playbook
   ansible-playbook playbooks/setup.yml -l masters
   ```

3. **Worker Nodes**
   ```bash
   # Run setup playbook
   ansible-playbook playbooks/setup.yml -l workers
   ```

## Verification

1. **Test Ansible Connectivity**
   ```bash
   ansible all -m ping
   ```

2. **Run Ad-hoc Commands**
   ```bash
   # Check system information
   ansible all -a "uname -a"

   # Check disk space
   ansible all -a "df -h"
   ```

3. **Verify Playbook Execution**
   ```bash
   ansible-playbook playbooks/setup.yml --check
   ```

## Troubleshooting

1. **SSH Issues**
   - Verify SSH keys
   - Check network connectivity
   - Review SSH logs

2. **Ansible Issues**
   - Check inventory file
   - Verify Python version
   - Review Ansible logs

3. **Node Issues**
   - Check node connectivity
   - Verify system requirements
   - Review system logs

For detailed troubleshooting steps, refer to `docs/troubleshooting.md`. 