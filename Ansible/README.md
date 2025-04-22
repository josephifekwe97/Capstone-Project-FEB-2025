# Kubernetes Cluster Configuration with Ansible

This project provides Ansible automation for setting up and configuring Kubernetes cluster nodes. It includes playbooks and roles for common configuration tasks, package installation, and security hardening.

## Documentation

The project documentation is organized in the `docs/` directory:

- [Setup Guide](docs/setup_guide.md): Comprehensive guide for setting up and configuring the cluster
- [Troubleshooting Guide](docs/troubleshooting.md): Detailed troubleshooting steps for common issues

## Project Structure

```
.
├── ansible.cfg           # Ansible configuration file
├── inventory/           # Inventory files
│   ├── hosts           # Main inventory file
│   └── group_vars/     # Group variables
├── roles/              # Ansible roles
│   ├── common/         # Common system configuration
│   ├── security/       # Security hardening
│   ├── kubernetes/     # Kubernetes specific setup
│   └── packages/       # Package management
├── playbooks/          # Main playbooks
│   ├── setup.yml       # Main setup playbook
│   └── security.yml    # Security hardening playbook
└── scripts/            # Helper scripts
    └── run.sh          # Main execution script
└── docs/               # Documentation
    ├── setup_guide.md  # Setup instructions
    └── troubleshooting.md  # Troubleshooting guide
```

## Prerequisites

- Ansible 2.9 or later
- Python 3.6 or later
- SSH access to target nodes
- Sudo privileges on target nodes

For detailed system requirements, see the [Setup Guide](docs/setup_guide.md#prerequisites).

## Quick Start

1. Configure your inventory in `inventory/hosts`
2. Adjust variables in `inventory/group_vars/`
3. Run the setup:

```bash
./scripts/run.sh
```

For detailed setup instructions, refer to the [Setup Guide](docs/setup_guide.md#installation).

## Roles

- **common**: Basic system configuration, timezone, hostname, etc.
- **security**: Security hardening tasks
- **kubernetes**: Kubernetes-specific configuration
- **packages**: Package installation and management

For detailed role descriptions and configuration options, see the [Setup Guide](docs/setup_guide.md#configuration).

## Security Considerations

- All playbooks include basic security hardening
- SSH key authentication is required
- Firewall rules are configured
- Regular security updates are enabled

For detailed security information, see the [Setup Guide](docs/setup_guide.md#security-considerations).

## Troubleshooting

Common issues and their solutions are documented in the [Troubleshooting Guide](docs/troubleshooting.md). This includes:

- SSH connection issues
- Package installation problems
- Kubernetes service issues
- Firewall configuration
- System resource issues
- Ansible playbook errors

## Support

For issues and support:
1. Check the [Troubleshooting Guide](docs/troubleshooting.md)
2. Review system logs
3. Consult the documentation
4. Contact the support team

## License

This project is licensed under the MIT License - see the LICENSE file for details. 