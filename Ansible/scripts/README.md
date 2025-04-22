# SSH Setup Script

This script automates the process of setting up SSH keys between your control node and all Kubernetes cluster nodes.

## Features

- Configuration file support (YAML format)
- Interactive menu-driven interface
- Parallel processing for faster setup
- Comprehensive logging system
- Backup and restore functionality
- Node health checks
- Color-coded output
- Error handling and status reporting
- Automatic SSH key generation
- Permission management
- Connection testing

## Prerequisites

- Bash shell
- SSH client installed
- AWS key pair file
- Access to all nodes via SSH
- `nc` (netcat) for port checking
- `yq` for YAML parsing (optional)

## Configuration

1. Copy the example configuration file:
   ```bash
   cp config.yaml.example config.yaml
   ```

2. Edit `config.yaml` with your settings:
   ```yaml
   aws_key:
     name: k8s-key.pem
     path: ~/Downloads/k8s-key.pem

   ssh:
     port: 22
     key_type: rsa
     key_bits: 4096

   nodes:
     control:
       name: control-node
       ip: 54.210.167.32
       user: ubuntu
     # ... other nodes ...
   ```

## Usage

1. Make the script executable:
   ```bash
   chmod +x setup_ssh.sh
   ```

2. Run the script:
   ```bash
   ./setup_ssh.sh
   ```

3. Use the interactive menu to:
   - Setup all nodes
   - Setup specific nodes
   - Check node health
   - Backup SSH files
   - Restore SSH files
   - View failed nodes

## Menu Options

1. **Setup all nodes**
   - Sets up SSH for all configured nodes
   - Runs in parallel for faster execution
   - Shows progress for each node

2. **Setup specific node**
   - Choose which node to setup
   - Useful for adding new nodes or fixing issues

3. **Check node health**
   - Verifies node reachability
   - Checks SSH port availability
   - Tests disk space
   - Validates SSH connectivity

4. **Backup SSH files**
   - Creates timestamped backups
   - Stores in configured backup directory
   - Includes all SSH-related files

5. **Restore SSH files**
   - Lists available backups
   - Restores from selected backup
   - Maintains file permissions

6. **Show failed nodes**
   - Lists nodes that failed setup
   - Shows error messages
   - Helps with troubleshooting

## Logging

The script creates detailed logs in the configured directory:
- Timestamps for all operations
- Success and error messages
- Command outputs
- Node health check results

Example log entry:
```
[2024-03-15 10:00:00] [INFO] Setting up SSH for master-1 (10.0.1.10)
[2024-03-15 10:00:01] [SUCCESS] Public key copied to master-1
```

## Backup System

The script automatically backs up SSH files:
- Creates timestamped directories
- Stores private and public keys
- Saves authorized_keys files
- Maintains backup history

## Error Handling

The script includes comprehensive error handling:
- IP address validation
- Connection testing
- Permission checking
- Command execution verification
- Failed node tracking

## Security Features

- Secure file permissions
- Backup before modifications
- Restore capability
- Health checks
- Logging of all operations

## Troubleshooting

1. **Permission denied errors**
   - Check AWS key permissions
   - Verify SSH directory permissions
   - Ensure correct user access

2. **Connection refused errors**
   - Verify IP addresses
   - Check security groups
   - Test network connectivity

3. **Invalid configuration**
   - Check YAML syntax
   - Verify all required fields
   - Ensure correct paths

## Support

For issues or questions:
1. Check the logs in the configured directory
2. Review the backup files if needed
3. Consult the troubleshooting section
4. Contact the support team 