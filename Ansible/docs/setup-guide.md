# Ansible Multi-Node Setup Guide

This guide provides detailed instructions for setting up Ansible across multiple nodes, including SSH automation, node configuration, and Kubernetes cluster setup.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [SSH Setup](#ssh-setup)
4. [Prerequisites Setup](#prerequisites-setup)
5. [Kubernetes Setup](#kubernetes-setup)
6. [Verification](#verification)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- Linux-based operating system (Ubuntu 20.04 or later recommended)
- Minimum 2GB RAM per node
- Minimum 2 CPU cores per node
- Root or sudo access on all nodes
- Internet connectivity on all nodes

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

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Install Basic Dependencies**
   ```bash
   # Install Python and pip
   sudo apt-get update
   sudo apt-get install -y python3 python3-pip
   ```

## SSH Setup

1. **Configure SSH Access**
   - Update `scripts/config.yml` with your node information:
     ```yaml
     nodes:
       control:
         name: "control"
         ip: "your-control-ip"
         user: "your-username"
       masters:
         - name: "master-1"
           ip: "your-master-ip"
           user: "your-username"
       workers:
         - name: "worker-1"
           ip: "your-worker-ip"
           user: "your-username"
     ```

2. **Run SSH Setup Script**
   ```bash
   # Make the script executable
   chmod +x scripts/setup_ssh.sh

   # Run the script
   ./scripts/setup_ssh.sh
   ```

3. **Verify SSH Access**
   ```bash
   # Test SSH to each node
   ssh user@node-ip
   ```

## Prerequisites Setup

1. **Run Prerequisites Script**
   ```bash
   # Make the script executable
   chmod +x scripts/setup_prerequisites.sh

   # Run the script
   ./scripts/setup_prerequisites.sh
   ```

2. **Verify Prerequisites**
   ```bash
   # Check Docker status
   sudo systemctl status docker

   # Check kernel modules
   lsmod | grep -e overlay -e br_netfilter

   # Check sysctl parameters
   sysctl net.bridge.bridge-nf-call-iptables net.ipv4.ip_forward net.bridge.bridge-nf-call-ip6tables
   ```

## Kubernetes Setup

1. **Update Inventory File**
   Create or update `inventory/hosts`:
   ```ini
   [control]
   control ansible_host=<control-ip> ansible_user=<your-username>

   [workers]
   worker-1 ansible_host=<worker-1-ip> ansible_user=<your-username>
   worker-2 ansible_host=<worker-2-ip> ansible_user=<your-username>
   ```

2. **Run Kubernetes Setup Script**
   ```bash
   # Make the script executable
   chmod +x scripts/setup_kubernetes.sh

   # Run the script
   ./scripts/setup_kubernetes.sh
   ```

3. **Verify Kubernetes Setup**
   ```bash
   # Check node status
   kubectl get nodes

   # Check pod status
   kubectl get pods --all-namespaces
   ```

## Verification

1. **Test Node Connectivity**
   ```bash
   # From control node
   kubectl get nodes
   ```

2. **Test Pod Deployment**
   ```bash
   # Deploy a test pod
   kubectl run nginx --image=nginx

   # Check pod status
   kubectl get pods
   ```

## Troubleshooting

For detailed troubleshooting steps, refer to [Troubleshooting Guide](docs/troubleshooting.md) 