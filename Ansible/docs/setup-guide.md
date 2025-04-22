# SSH Setup and Monitoring Tool - Setup Guide

This guide provides detailed instructions for setting up and using the SSH Setup and Monitoring Tool.

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Usage](#usage)
5. [Monitoring](#monitoring)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements
- Linux-based operating system
- Bash shell
- SSH client
- Required commands on target nodes:
  - `top`
  - `free`
  - `df`
  - `uptime`
  - `ssh`
  - `mkdir`
  - `chmod`

### Software Dependencies
```bash
# Install required packages
# For Ubuntu/Debian:
sudo apt-get update
sudo apt-get install -y yq ssh

# For CentOS/RHEL:
sudo yum install -y yq openssh-clients
```

### Network Requirements
- SSH access to all nodes
- Network connectivity between all nodes
- Firewall rules allowing SSH traffic (port 22)

### Directory Structure
```bash
# Create required directories
mkdir -p ~/.ssh
mkdir -p ~/.ssh/backup
mkdir -p ~/.ssh/logs

# Set proper permissions
chmod 700 ~/.ssh
chmod 700 ~/.ssh/backup
chmod 700 ~/.ssh/logs
```

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Make the script executable:
   ```bash
   chmod +x scripts/setup_ssh.sh
   ```

3. Configure the `config.yml` file:
   ```bash
   cp scripts/config.yml.example scripts/config.yml
   nano scripts/config.yml
   ```

## Configuration

### config.yml Structure
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
    # Add more master nodes as needed
  workers:
    - name: "worker-1"
      ip: "your-worker-ip"
      user: "your-username"
    # Add more worker nodes as needed
```

### Required Fields
- `name`: Node identifier
- `ip`: IP address of the node
- `user`: Username for SSH access

## Usage

### Starting the Tool
```bash
./scripts/setup_ssh.sh
```

### Main Menu Options

1. **Setup all nodes**
   - Configures SSH access for all nodes
   - Tests connectivity between nodes
   - Creates necessary directories and sets permissions

2. **Setup specific node**
   - Configure SSH access for a single node
   - Useful for adding new nodes or fixing issues

3. **Show failed nodes**
   - Displays nodes that failed setup
   - Shows error messages and last attempt details

4. **View logs**
   - Displays detailed operation logs
   - Helps in troubleshooting issues

5. **Show node status**
   - Displays current status of all nodes
   - Shows online/offline status

6. **Monitor nodes**
   - Real-time monitoring of node metrics
   - Interactive connectivity matrix
   - Press 'q' to quit monitoring

7. **Cleanup temporary files**
   - Removes temporary SSH key files
   - Cleans up backup files if needed

8. **Exit**
   - Safely exits the tool
   - Performs cleanup if needed

## Monitoring

### Real-time Metrics
The monitoring feature displays:
- CPU usage
- Memory usage
- Disk usage
- System uptime
- System load

### Connectivity Matrix
- Shows connection status between all nodes
- Green checkmark (✓) for successful connections
- Red cross (✗) for failed connections
- Diagonal marked with "-" (self-connection)

### Auto-refresh
- Updates every 5 seconds
- Press 'q' to quit monitoring
- Color-coded output for easy status identification

## Troubleshooting

### Common Issues

1. **SSH Connection Failures**
   ```bash
   # Test SSH connection manually
   ssh -v user@ip
   
   # Check SSH service status
   systemctl status ssh
   
   # Verify firewall rules
   sudo ufw status
   ```

2. **Permission Issues**
   ```bash
   # Check directory permissions
   ls -la ~/.ssh
   
   # Check key file permissions
   ls -l ~/.ssh/id_rsa
   
   # Fix permissions if needed
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_rsa
   ```

3. **Monitoring Issues**
   ```bash
   # Verify required commands on target nodes
   ssh user@ip "which top free df uptime"
   
   # Check network connectivity
   ping ip
   nc -zv ip 22
   ```

### Log Files
- Location: `~/.ssh/logs/`
- Format: `ssh_setup_YYYYMMDD_HHMMSS.log`
- Contains detailed operation logs

### Backup Files
- Location: `~/.ssh/backup/`
- Format: `ssh_key_YYYYMMDD_HHMMSS.pem`
- Contains backup copies of SSH keys

## Best Practices

1. **Security**
   - Use strong SSH keys (RSA 4096-bit minimum)
   - Regularly rotate SSH keys
   - Keep backup copies of keys
   - Monitor access logs

2. **Maintenance**
   - Regularly check node status
   - Monitor system metrics
   - Clean up old backup files
   - Update configuration as needed

3. **Documentation**
   - Keep configuration files updated
   - Document any custom changes
   - Maintain a changelog
   - Update this guide as needed 