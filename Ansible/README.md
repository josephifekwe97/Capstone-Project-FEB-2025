# SSH Setup and Monitoring Tool

A comprehensive tool for setting up SSH access and monitoring across a cluster of nodes. This tool automates the process of configuring SSH keys, testing connectivity, and monitoring node health.

## Features

- **SSH Key Management**
  - Import existing SSH keys or create new ones
  - Automatic backup of SSH keys
  - Secure key file permissions

- **Node Configuration**
  - Support for control, master, and worker nodes
  - Automated SSH setup for all nodes
  - Individual node setup capability
  - Connectivity testing between nodes

- **Monitoring**
  - Real-time system metrics (CPU, Memory, Disk, Uptime, Load)
  - Interactive connectivity matrix
  - Auto-refreshing status display
  - Color-coded output for easy status identification

- **Security**
  - Secure key file handling
  - Temporary file cleanup
  - Proper file permissions
  - Backup management

## Requirements

- **System Requirements**
  - Bash shell
  - SSH client
  - `yq` (YAML processor) or grep/awk for YAML parsing
  - `timeout` command
  - `top`, `free`, `df`, `uptime` commands on target nodes

- **Network Requirements**
  - SSH access to all nodes
  - Network connectivity between all nodes
  - Proper firewall rules to allow SSH traffic

- **Permissions**
  - Write access to `~/.ssh` directory
  - SSH access to all target nodes
  - Sudo privileges on target nodes (for some operations)

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Install required dependencies:
   ```bash
   # For Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install -y yq ssh

   # For CentOS/RHEL
   sudo yum install -y yq openssh-clients
   ```

3. Configure the `config.yml` file:
   - Update node information (IPs, usernames)
   - Ensure all required fields are filled

4. Make the script executable:
   ```bash
   chmod +x scripts/setup_ssh.sh
   ```

## Usage

1. Run the script:
   ```bash
   ./scripts/setup_ssh.sh
   ```

2. Main Menu Options:
   - Setup all nodes
   - Setup specific node
   - Show failed nodes
   - View logs
   - Show node status
   - Monitor nodes
   - Cleanup temporary files
   - Exit

3. Monitoring:
   - Press 'q' to quit monitoring
   - Auto-refreshes every 5 seconds
   - Shows real-time metrics and connectivity status

## Configuration

The `config.yml` file should contain:

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

## Security Notes

- SSH keys are stored with 600 permissions
- Temporary files are automatically cleaned up
- Backups are created with secure permissions
- All sensitive operations are logged

## Troubleshooting

1. **SSH Connection Issues**
   - Verify network connectivity
   - Check firewall rules
   - Ensure SSH service is running on target nodes
   - Verify username and IP addresses

2. **Permission Issues**
   - Check `~/.ssh` directory permissions
   - Verify key file permissions
   - Ensure proper user permissions on target nodes

3. **Monitoring Issues**
   - Verify required commands are available on target nodes
   - Check network connectivity
   - Ensure SSH keys are properly set up

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

[Your License Here]

## Support

For support, please [create an issue](<repository-url>/issues) in the repository. 