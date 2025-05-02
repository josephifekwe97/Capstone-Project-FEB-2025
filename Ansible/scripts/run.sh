#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check for Ansible
if ! command_exists ansible; then
    echo -e "${RED}Error: Ansible is not installed.${NC}"
    echo "Please install Ansible first:"
    echo "  For Ubuntu/Debian: sudo apt install ansible"
    echo "  For CentOS/RHEL: sudo yum install ansible"
    exit 1
fi

# Function to run playbook with error handling
run_playbook() {
    local playbook=$1
    local tags=$2
    
    echo -e "${YELLOW}Running playbook: $playbook${NC}"
    if [ -z "$tags" ]; then
        ansible-playbook playbooks/$playbook
    else
        ansible-playbook playbooks/$playbook --tags "$tags"
    fi
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error running playbook: $playbook${NC}"
        exit 1
    fi
}

# Main menu
while true; do
    echo -e "\n${GREEN}Kubernetes Cluster Configuration Menu${NC}"
    echo "1. Full Setup (All roles)"
    echo "2. Security Hardening Only"
    echo "3. Check System Requirements"
    echo "4. Exit"
    
    read -p "Enter your choice (1-4): " choice
    
    case $choice in
        1)
            run_playbook "setup.yml"
            ;;
        2)
            run_playbook "security.yml"
            ;;
        3)
            ansible-playbook playbooks/setup.yml --tags "check"
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid choice. Please try again.${NC}"
            ;;
    esac
done 