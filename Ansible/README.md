# Ansible Multi-Node Setup Project

A comprehensive project for setting up and managing Ansible across multiple nodes. This project includes tools for automating SSH setup, node configuration, and Ansible deployment.

## Getting Started

To get started with this project, follow these steps:

1. **Quick Start**
   - Clone the repository
   - Review the [Setup Guide](docs/setup-guide.md) for detailed instructions
   - Configure your nodes in `scripts/config.yml`
   - Run the SSH setup script: `./scripts/setup_ssh.sh`

2. **Documentation**
   - [Setup Guide](docs/setup-guide.md): Step-by-step instructions for setting up your environment
   - [Troubleshooting](docs/troubleshooting.md): Common issues and their solutions
   - [Configuration](docs/setup_guide.md): Detailed configuration options

3. **Need Help?**
   - Check the [troubleshooting guide](docs/troubleshooting.md) for common issues
   - Create an issue in the repository for support

## Project Structure

- **Ansible Configuration**
  - `ansible.cfg`: Main Ansible configuration file
  - `inventory/`: Node inventory files
  - `playbooks/`: Ansible playbooks
  - `roles/`: Reusable Ansible roles

- **SSH Automation Tool**
  - `scripts/setup_ssh.sh`: Automated SSH setup script
  - `scripts/config.yml`: SSH configuration file

## Features

- **Ansible Setup**
  - Multi-node inventory management
  - Role-based configuration
  - Playbook automation
  - Custom Ansible configuration

- **SSH Automation**
  - Automated SSH key setup
  - Node-to-node connectivity
  - Secure key management
  - Node monitoring

- **Node Management**
  - Control node setup
  - Master node configuration
  - Worker node deployment
  - Health monitoring

## Requirements

- **System Requirements**
  - Linux-based operating system
  - Python 3.x
  - Ansible
  - SSH client
  - `yq` (YAML processor)

- **Network Requirements**
  - SSH access to all nodes
  - Network connectivity between nodes
  - Proper firewall configuration

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. Install Ansible and dependencies:
   ```bash
   # Install Python requirements
   pip install -r requirements.txt

   # Install system dependencies
   sudo apt-get update
   sudo apt-get install -y ansible ssh yq
   ```

3. Configure SSH access:
   ```bash
   # Run the SSH setup script
   ./scripts/setup_ssh.sh
   ```

4. Configure Ansible:
   - Update `ansible.cfg` as needed
   - Configure inventory files in `inventory/`
   - Set up roles in `roles/`

## Usage

1. **SSH Setup**
   ```bash
   ./scripts/setup_ssh.sh
   ```
   - Follow the menu to setup SSH access
   - Monitor node connectivity
   - Manage SSH keys

2. **Ansible Deployment**
   ```bash
   # Run playbooks
   ansible-playbook playbooks/setup.yml

   # Test connectivity
   ansible all -m ping
   ```

3. **Node Management**
   ```bash
   # List all nodes
   ansible-inventory --list

   # Run ad-hoc commands
   ansible all -a "uname -a"
   ```

## Configuration

1. **SSH Configuration**
   Update `scripts/config.yml`:
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

2. **Ansible Configuration**
   - Update `ansible.cfg` for your environment
   - Configure inventory files
   - Customize roles as needed

## Documentation

- `docs/setup-guide.md`: Detailed setup instructions
- `docs/troubleshooting.md`: Common issues and solutions
- `docs/setup_guide.md`: Step-by-step deployment guide

## Security

- SSH keys with proper permissions
- Secure Ansible configuration
- Role-based access control
- Audit logging

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License

Copyright (c) 2024

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Support

For support, please [create an issue](<repository-url>/issues) in the repository. 