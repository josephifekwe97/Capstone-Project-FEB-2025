# Kubernetes Cluster Setup using Ansible

This project automates the setup of a Kubernetes cluster using Ansible. The setup includes a control node, master nodes, and worker nodes.

## Prerequisites

- AWS account (or any cloud provider)
- Basic knowledge of Linux commands
- SSH key pair
- Ansible (will be installed during setup)

## Instance Setup

1. Create the following instances in your cloud provider:
   - 1 Control Node
   - 3 Master Nodes
   - 2 Worker Nodes

2. **Important Security Group Configuration**:
   - Allow ingress traffic on port 6443 for the API server
   - Allow SSH access (port 22) from your IP address
   - Allow internal communication between all nodes

## Initial Setup

1. Clone this repository to your local machine:
   ```bash
   git clone <repository-url>
   cd ans-cluster
   ```

2. Navigate to the scripts directory:
   ```bash
   cd scripts
   ```

3. Modify the `config.yml` file:
   - Replace the IP addresses with your actual instance IPs
   - Update the usernames if different from 'ubuntu'

4. Make the setup script executable and run it:
   ```bash
   chmod +x setup_ssh.sh
   ./setup_ssh.sh
   ```
   This script will set up SSH access between all nodes.

## Control Node Setup

1. SSH into your control node using your key:
   ```bash
   ssh -i key.pem ubuntu@<control-node-ip>
   ```

2. Update and upgrade the system:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

3. Install Ansible:
   ```bash
   sudo apt install ansible -y
   ```

4. Clone the repository on the control node:
   ```bash
   git clone <repository-url>
   cd ans-cluster
   ```

5. Modify the `hosts` file:
   - Update the IP addresses to match your instances
   - Ensure the groups are correctly defined

## Deploying the Cluster

1. From the control node, run the Ansible playbook:
   ```bash
   ansible-playbook -i hosts site.yml
   ```

2. Wait for the playbook to complete. This will:
   - Set up the network configuration
   - Configure the master nodes
   - Configure the worker nodes
   - Join the worker nodes to the cluster

## Verifying the Cluster

1. SSH into one of the master nodes using your key:
   ```bash
   ssh -i key.pem ubuntu@<master-node-ip>
   ```

2. Check the cluster status:
   ```bash
   kubectl get nodes
   ```
   You should see all your nodes listed with a "Ready" status.

## Accessing the Cluster from Local Machine

1. Install `kubectl` on your local machine:
   ```bash
   # For Ubuntu/Debian
   sudo apt-get update && sudo apt-get install -y kubectl
   
   # For macOS
   brew install kubectl
   ```

2. Copy the kubeconfig file from the master node using your key:
   ```bash
   scp -i key.pem ubuntu@<master-node-ip>:/home/ubuntu/.kube/config ~/.kube/config
   ```

3. Verify you can access the cluster:
   ```bash
   kubectl get nodes
   ```

## Troubleshooting

If you encounter any issues:
1. Check the Ansible logs for errors
2. Verify SSH connectivity between nodes
3. Ensure all required ports are open in the security groups
4. Check the Kubernetes logs on the master nodes:
   ```bash
   journalctl -u kubelet
   ```

## Security Notes

- Keep your SSH keys secure
- Regularly update your instances
- Monitor the cluster for any security issues
- Consider implementing additional security measures like RBAC

## Support

For any issues or questions, please open an issue in the repository. 