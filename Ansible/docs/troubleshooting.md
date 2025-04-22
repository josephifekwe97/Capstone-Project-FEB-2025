# Troubleshooting Guide

This guide provides detailed troubleshooting steps for common issues that may arise during the setup and operation of the Kubernetes cluster using Ansible.

## Table of Contents
1. [SSH Connection Issues](#ssh-connection-issues)
2. [Package Installation Problems](#package-installation-problems)
3. [Kubernetes Service Issues](#kubernetes-service-issues)
4. [Firewall Configuration](#firewall-configuration)
5. [System Resource Issues](#system-resource-issues)
6. [Ansible Playbook Errors](#ansible-playbook-errors)

## SSH Connection Issues

### Symptoms
- Connection timeouts
- Permission denied errors
- Host key verification failures

### Solutions

1. **Verify SSH Configuration**
   ```bash
   # Check SSH service status
   systemctl status sshd
   
   # Check SSH configuration
   cat /etc/ssh/sshd_config
   ```

2. **Check SSH Keys**
   ```bash
   # Verify key permissions
   ls -la ~/.ssh/
   
   # Test SSH connection
   ssh -v user@target-node
   ```

3. **Firewall Rules**
   ```bash
   # Check UFW status
   sudo ufw status
   
   # Check iptables rules
   sudo iptables -L
   ```

## Package Installation Problems

### Symptoms
- Package not found errors
- Dependency resolution failures
- Repository connection issues

### Solutions

1. **Update Package Lists**
   ```bash
   # For Ubuntu/Debian
   sudo apt update
   
   # For CentOS/RHEL
   sudo yum update
   ```

2. **Check Repository Configuration**
   ```bash
   # For Ubuntu/Debian
   cat /etc/apt/sources.list
   
   # For CentOS/RHEL
   cat /etc/yum.repos.d/*
   ```

3. **Clear Package Cache**
   ```bash
   # For Ubuntu/Debian
   sudo apt clean
   sudo apt autoclean
   
   # For CentOS/RHEL
   sudo yum clean all
   ```

## Kubernetes Service Issues

### Symptoms
- kubelet service failures
- Container runtime issues
- Network connectivity problems

### Solutions

1. **Check Service Status**
   ```bash
   # Check kubelet status
   systemctl status kubelet
   
   # Check Docker status
   systemctl status docker
   ```

2. **View Service Logs**
   ```bash
   # View kubelet logs
   journalctl -u kubelet -f
   
   # View Docker logs
   journalctl -u docker -f
   ```

3. **Verify Network Configuration**
   ```bash
   # Check network interfaces
   ip addr show
   
   # Check routing table
   ip route show
   ```

## Firewall Configuration

### Symptoms
- Service connection failures
- Port access denied
- Network connectivity issues

### Solutions

1. **Check Firewall Status**
   ```bash
   # Check UFW status
   sudo ufw status verbose
   
   # Check iptables rules
   sudo iptables -L -n -v
   ```

2. **Verify Port Configuration**
   ```bash
   # Check open ports
   sudo netstat -tulpn
   
   # Test port connectivity
   nc -zv host port
   ```

3. **Reset Firewall Rules**
   ```bash
   # Reset UFW
   sudo ufw reset
   
   # Reset iptables
   sudo iptables -F
   ```

## System Resource Issues

### Symptoms
- High CPU usage
- Memory exhaustion
- Disk space problems

### Solutions

1. **Check System Resources**
   ```bash
   # Check CPU usage
   top
   
   # Check memory usage
   free -h
   
   # Check disk space
   df -h
   ```

2. **Clean Up Resources**
   ```bash
   # Clean Docker resources
   docker system prune -a
   
   # Clean Kubernetes resources
   kubectl delete --all pods --namespace=default
   ```

3. **Adjust Resource Limits**
   ```bash
   # Check system limits
   ulimit -a
   
   # Check process limits
   cat /proc/$(pgrep kubelet)/limits
   ```

## Ansible Playbook Errors

### Symptoms
- Playbook execution failures
- Role execution errors
- Variable resolution problems

### Solutions

1. **Enable Verbose Output**
   ```bash
   # Run playbook with verbose output
   ansible-playbook -vvv playbooks/setup.yml
   ```

2. **Check Variable Values**
   ```bash
   # Debug variable values
   ansible-playbook --check playbooks/setup.yml
   ```

3. **Verify Inventory**
   ```bash
   # Test inventory
   ansible-inventory --list
   
   # Test connectivity
   ansible all -m ping
   ```

## Common Error Messages and Solutions

### "Permission Denied" Error
```bash
# Solution: Check and fix permissions
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

### "Package Not Found" Error
```bash
# Solution: Add required repository
sudo add-apt-repository ppa:repository-name
sudo apt update
```

### "Service Failed to Start" Error
```bash
# Solution: Check service configuration
systemctl status service-name
journalctl -u service-name
```

### "Connection Refused" Error
```bash
# Solution: Check firewall and service status
sudo ufw status
systemctl status service-name
```

## Getting Help

If you encounter issues not covered in this guide:

1. Check the system logs:
   ```bash
   journalctl -xe
   ```

2. Review Ansible logs:
   ```bash
   cat /var/log/ansible.log
   ```

3. Check Kubernetes documentation:
   ```bash
   kubectl explain resource
   ```

4. Contact support with:
   - Error messages
   - System logs
   - Ansible playbook output
   - Environment details 