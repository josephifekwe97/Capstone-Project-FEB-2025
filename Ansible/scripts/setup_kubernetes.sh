#!/bin/bash

# Function to print status messages
print_status() {
    echo -e "\n\033[1;34m==> $1\033[0m"
}

# Function to print error messages
print_error() {
    echo -e "\n\033[1;31mError: $1\033[0m"
    exit 1
}

# Check if inventory file exists
if [ ! -f "inventory/hosts" ]; then
    print_error "Inventory file not found. Please create inventory/hosts first."
fi

# Check if Ansible is installed
if ! command -v ansible >/dev/null 2>&1; then
    print_error "Ansible is not installed. Please run setup_prerequisites.sh first."
fi

# Check if Docker is running
if ! systemctl is-active --quiet docker; then
    print_error "Docker is not running. Please run setup_prerequisites.sh first."
fi

# Run the Kubernetes setup playbook
print_status "Setting up Kubernetes cluster..."
ansible-playbook -i inventory/hosts playbooks/kubernetes_setup.yml || print_error "Failed to set up Kubernetes cluster"

# Get the control node IP from inventory
CONTROL_IP=$(grep -A1 "\[control\]" inventory/hosts | tail -n1 | awk '{print $2}' | cut -d'=' -f2)

# Copy kubeconfig to local machine
print_status "Copying kubeconfig to local machine..."
mkdir -p ~/.kube
scp ${CONTROL_IP}:~/.kube/config ~/.kube/config || print_error "Failed to copy kubeconfig"

# Verify Kubernetes setup
print_status "Verifying Kubernetes setup..."
kubectl get nodes || print_error "Failed to verify Kubernetes setup"

print_status "Kubernetes cluster has been set up successfully!" 