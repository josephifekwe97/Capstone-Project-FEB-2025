# Troubleshooting Guide

This guide covers common issues encountered while using the SSH Setup and Monitoring Tool, their causes, and solutions.

## Table of Contents
1. [SSH Connection Issues](#ssh-connection-issues)
2. [Configuration Issues](#configuration-issues)
3. [Monitoring Issues](#monitoring-issues)
4. [Permission Issues](#permission-issues)
5. [Network Issues](#network-issues)
6. [Script Execution Issues](#script-execution-issues)

## SSH Connection Issues

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

### 2. Node Information Not Found
**Symptoms:**
- "Node not found" errors
- Missing IP addresses
- Debug output mixed with values

**Causes:**
- Incorrect node names
- Missing sections in config
- YAML parsing issues

**Solutions:**
```bash
# Verify node names
cat scripts/config.yml

# Check yq installation
which yq

# Use grep/awk as fallback
grep -A 3 "name:" scripts/config.yml
```

## Monitoring Issues

### 1. Metrics Not Displaying
**Symptoms:**
- Blank metrics
- "Command not found" errors
- Incomplete information

**Causes:**
- Required commands missing on target nodes
- Permission issues
- Network connectivity problems

**Solutions:**
```bash
# Check required commands
ssh user@target-ip "which top free df uptime"

# Install missing packages
ssh user@target-ip "sudo apt-get install -y procps util-linux"

# Verify permissions
ssh user@target-ip "ls -l /usr/bin/top"
```

### 2. Connectivity Matrix Issues
**Symptoms:**
- Incorrect connection status
- Missing nodes in matrix
- False positives/negatives

**Causes:**
- SSH key issues
- Network latency
- Timeout settings too low

**Solutions:**
```bash
# Increase timeout in script
# Edit setup_ssh.sh and modify:
timeout=15  # Increase this value

# Verify SSH keys
ssh user@target-ip "ls -l ~/.ssh/id_rsa"

# Test connectivity manually
ssh user@source-ip "ssh user@target-ip 'echo test'"
```

## Permission Issues

### 1. Directory Permission Errors
**Symptoms:**
- "Permission denied" errors
- Cannot create directories
- Cannot write files

**Causes:**
- Incorrect directory permissions
- Wrong ownership
- SELinux/AppArmor restrictions

**Solutions:**
```bash
# Fix directory permissions
chmod 700 ~/.ssh
chmod 700 ~/.ssh/backup
chmod 700 ~/.ssh/logs

# Check ownership
ls -la ~/.ssh

# Fix ownership if needed
chown -R $USER:$USER ~/.ssh
```

### 2. Key File Permission Issues
**Symptoms:**
- "Bad permissions" warnings
- Key not accepted
- Authentication failures

**Causes:**
- Too permissive key file
- Wrong ownership
- Group/other permissions

**Solutions:**
```bash
# Fix key permissions
chmod 600 ~/.ssh/tmp_ssh_key.pem
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

# Check ownership
ls -l ~/.ssh/*.pem
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

## Script Execution Issues

### 1. Command Not Found
**Symptoms:**
- "Command not found" errors
- Script fails to start
- Missing dependencies

**Causes:**
- Missing required packages
- PATH issues
- Incomplete installation

**Solutions:**
```bash
# Install required packages
sudo apt-get update
sudo apt-get install -y yq ssh

# Check PATH
echo $PATH

# Verify command locations
which ssh yq timeout
```

### 2. Script Hangs
**Symptoms:**
- Script becomes unresponsive
- No output for long periods
- Cannot interrupt with Ctrl+C

**Causes:**
- Long-running SSH commands
- Network timeouts
- Process stuck

**Solutions:**
```bash
# Kill hanging processes
pkill -f setup_ssh.sh

# Check for zombie processes
ps aux | grep defunct

# Increase timeout values
# Edit setup_ssh.sh and modify:
timeout=30  # Increase this value
```

## Best Practices for Troubleshooting

1. **Check Logs First**
   ```bash
   # View recent logs
   tail -f ~/.ssh/logs/ssh_setup_*.log
   ```

2. **Verify Configuration**
   ```bash
   # Check config file
   cat scripts/config.yml
   
   # Validate YAML
   yq eval scripts/config.yml
   ```

3. **Test Manually**
   ```bash
   # Test SSH connection
   ssh -v user@ip
   
   # Check key permissions
   ls -l ~/.ssh/
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