#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status messages
print_status() {
    echo -e "\n\033[1;34m==> $1\033[0m"
}

# Function to print error messages
print_error() {
    echo -e "\n\033[1;31mError: $1\033[0m"
    exit 1
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run as root"
fi

# Update package index
print_status "Updating package index..."
apt-get update || print_error "Failed to update package index"

# Install required packages
print_status "Installing required packages..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    python3-pip \
    ansible || print_error "Failed to install required packages"

# Install Docker
print_status "Installing Docker..."
if ! command_exists docker; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io || print_error "Failed to install Docker"
fi

# Configure Docker
print_status "Configuring Docker..."
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Start and enable Docker
print_status "Starting Docker service..."
systemctl enable docker
systemctl start docker || print_error "Failed to start Docker service"

# Disable swap
print_status "Disabling swap..."
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Enable kernel modules
print_status "Enabling kernel modules..."
modprobe overlay
modprobe br_netfilter

# Configure sysctl
print_status "Configuring sysctl parameters..."
cat > /etc/sysctl.d/99-kubernetes-cri.conf <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

# Install Ansible requirements
print_status "Installing Ansible requirements..."
pip3 install kubernetes
ansible-galaxy collection install community.general
ansible-galaxy collection install kubernetes.core

# Verify installations
print_status "Verifying installations..."
if ! command_exists docker; then
    print_error "Docker installation failed"
fi

if ! command_exists ansible; then
    print_error "Ansible installation failed"
fi

# Check kernel modules
if ! lsmod | grep -q overlay || ! lsmod | grep -q br_netfilter; then
    print_error "Required kernel modules are not loaded"
fi

# Check sysctl parameters
if ! sysctl net.bridge.bridge-nf-call-iptables | grep -q "1" || \
   ! sysctl net.ipv4.ip_forward | grep -q "1" || \
   ! sysctl net.bridge.bridge-nf-call-ip6tables | grep -q "1"; then
    print_error "Sysctl parameters are not properly configured"
fi

print_status "All prerequisites have been installed and configured successfully!" 