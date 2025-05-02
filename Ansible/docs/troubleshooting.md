# Troubleshooting Guide

This guide covers common issues encountered while setting up and using Ansible with SSH automation.

## Table of Contents
1. [SSH Issues](#ssh-issues)
2. [Ansible Issues](#ansible-issues)
3. [Node Issues](#node-issues)
4. [Configuration Issues](#configuration-issues)
5. [Network Issues](#network-issues)

## SSH Issues

### 1. SSH Key Not Found
**Symptoms:**
- Error: "No SSH key found. Please setup nodes first"
- Unable to proceed with node setup

**Causes:**
- Temporary key file not created
- Key file deleted or moved
- Permission issues with key file

**Solutions:**
```bash
# Verify key file exists
ls -l ~/.ssh/tmp_ssh_key.pem

# Check key file permissions
chmod 600 ~/.ssh/tmp_ssh_key.pem

# If key is missing, run setup again
./scripts/setup_ssh.sh
```

### 2. SSH Connection Timeout
**Symptoms:**
- Connection attempts timeout
- "Connection timed out" errors
- Multiple retry attempts fail

**Causes:**
- Network connectivity issues
- Firewall blocking SSH
- Target node not responding
- Incorrect IP address

**Solutions:**
```bash
# Test basic connectivity
ping <target-ip>

# Check SSH service on target
ssh user@target-ip "systemctl status ssh"

# Verify firewall rules
sudo ufw status

# Check SSH port
nc -zv <target-ip> 22
```

### 3. Authentication Failures
**Symptoms:**
- "Permission denied" errors
- Authentication failures
- Key not accepted

**Causes:**
- Incorrect username
- Key not properly copied
- Wrong permissions on authorized_keys
- SSH service configuration issues

**Solutions:**
```bash
# Verify username in config
cat scripts/config.yml

# Check authorized_keys permissions
ssh user@target-ip "ls -l ~/.ssh/authorized_keys"

# Fix permissions if needed
ssh user@target-ip "chmod 600 ~/.ssh/authorized_keys"

# Check SSH service config
ssh user@target-ip "sudo cat /etc/ssh/sshd_config"
```

## Ansible Issues

### 1. Inventory Problems
**Symptoms:**
- "No hosts matched" errors
- Inventory parsing errors
- Missing host variables

**Causes:**
- Incorrect inventory file format
- Missing host definitions
- Invalid host patterns

**Solutions:**
```bash
# Verify inventory file
cat inventory/hosts

# Test inventory parsing
ansible-inventory --list

# Check host patterns
ansible all --list-hosts
```

### 2. Playbook Execution Failures
**Symptoms:**
- Playbook fails to start
- Task execution errors
- Permission denied errors

**Causes:**
- Missing dependencies
- Incorrect task syntax
- Permission issues
- Network connectivity problems

**Solutions:**
```bash
# Check playbook syntax
ansible-playbook playbooks/setup.yml --syntax-check

# Run in check mode
ansible-playbook playbooks/setup.yml --check

# Increase verbosity
ansible-playbook playbooks/setup.yml -vvv
```

### 3. Module Errors
**Symptoms:**
- Module not found errors
- Module execution failures
- Python dependency errors

**Causes:**
- Missing Python packages
- Incorrect module paths
- Version incompatibilities

**Solutions:**
```bash
# Install required Python packages
ansible all -m raw -a "pip install required-package"

# Check module paths
ansible-config dump | grep DEFAULT_MODULE_PATH

# Verify Python version
ansible all -m raw -a "python --version"
```

## Node Issues

### 1. Control Node Problems
**Symptoms:**
- Ansible commands fail
- Inventory access issues
- Playbook execution errors

**Causes:**
- Ansible installation issues
- Configuration problems
- Permission issues

**Solutions:**
```bash
# Verify Ansible installation
ansible --version

# Check configuration
ansible-config dump

# Test local connectivity
ansible localhost -m ping
```

### 2. Target Node Issues
**Symptoms:**
- Node unreachable
- Command execution failures
- Permission denied errors

**Causes:**
- SSH connectivity issues
- Missing dependencies
- Permission problems

**Solutions:**
```bash
# Test SSH connectivity
ansible target-node -m ping

# Check system requirements
ansible target-node -m raw -a "uname -a"

# Verify Python installation
ansible target-node -m raw -a "which python"
```

## Configuration Issues

### 1. YAML Parsing Errors
**Symptoms:**
- "Invalid YAML" errors
- Missing node information
- Incorrect IP/username display

**Causes:**
- Malformed config.yml
- Missing required fields
- Incorrect indentation
- Special characters in values

**Solutions:**
```bash
# Validate YAML syntax
yq eval scripts/config.yml

# Check required fields
cat scripts/config.yml

# Fix indentation
nano scripts/config.yml
```

### 2. Ansible Configuration Problems
**Symptoms:**
- Configuration not applied
- Unexpected behavior
- Permission errors

**Causes:**
- Incorrect ansible.cfg
- Conflicting settings
- Permission issues

**Solutions:**
```bash
# Check current configuration
ansible-config dump

# Verify configuration file
cat ansible.cfg

# Test configuration
ansible all -m ping
```

## Network Issues

### 1. Intermittent Connectivity
**Symptoms:**
- Random connection drops
- Inconsistent monitoring
- Timeout errors

**Causes:**
- Network instability
- High latency
- Bandwidth issues
- Firewall rules

**Solutions:**
```bash
# Check network stability
ping -c 10 <target-ip>

# Monitor latency
mtr <target-ip>

# Check firewall rules
sudo iptables -L

# Verify bandwidth
iperf3 -c <target-ip>
```

### 2. DNS Resolution Issues
**Symptoms:**
- Hostname resolution failures
- IP address not found
- Connection refused

**Causes:**
- DNS configuration issues
- Hostname not in /etc/hosts
- Network configuration problems

**Solutions:**
```bash
# Check DNS resolution
nslookup <hostname>

# Verify /etc/hosts
cat /etc/hosts

# Test direct IP connection
ssh user@<ip-address>
```

## Best Practices for Troubleshooting

1. **Check Logs First**
   ```bash
   # View Ansible logs
   tail -f /var/log/ansible.log

   # View SSH logs
   tail -f /var/log/auth.log
   ```

2. **Verify Configuration**
   ```bash
   # Check all configurations
   ansible-config dump
   cat ansible.cfg
   cat scripts/config.yml
   ```

3. **Test Manually**
   ```bash
   # Test SSH
   ssh -v user@ip

   # Test Ansible
   ansible all -m ping
   ```

4. **Monitor Resources**
   ```bash
   # Check system resources
   top

   # Monitor network
   netstat -tulpn
   ```

5. **Document Issues**
   - Record error messages
   - Note timing of issues
   - Document attempted solutions
   - Update this guide with new findings 