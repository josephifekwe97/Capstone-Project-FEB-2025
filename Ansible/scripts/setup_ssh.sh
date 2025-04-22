#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration file
CONFIG_FILE="config.yaml"
LOG_FILE=""
BACKUP_DIR=""
declare -A NODES
declare -a FAILED_NODES=()

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$status" in
        "success")
            echo -e "${GREEN}[SUCCESS]${NC} $message"
            log_message "SUCCESS" "$message"
            ;;
        "error")
            echo -e "${RED}[ERROR]${NC} $message"
            log_message "ERROR" "$message"
            ;;
        "info")
            echo -e "${YELLOW}[INFO]${NC} $message"
            log_message "INFO" "$message"
            ;;
        "debug")
            echo -e "${BLUE}[DEBUG]${NC} $message"
            log_message "DEBUG" "$message"
            ;;
    esac
}

# Function to log messages
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    if [ -n "$LOG_FILE" ]; then
        echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    fi
}

# Function to check if a command was successful
check_command() {
    if [ $? -eq 0 ]; then
        print_status "success" "$1"
        return 0
    else
        print_status "error" "$2"
        return 1
    fi
}

# Function to get user input with validation
get_input() {
    local prompt=$1
    local default=$2
    local input
    
    while true; do
        read -p "$prompt [$default]: " input
        input=${input:-$default}
        
        if [ -z "$input" ]; then
            print_status "error" "Input cannot be empty"
        else
            echo "$input"
            break
        fi
    done
}

# Function to validate IP address
validate_ip() {
    local ip=$1
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to backup SSH files
backup_ssh_files() {
    local node=$1
    local backup_dir="$BACKUP_DIR/$(date +%Y%m%d_%H%M%S)_$node"
    
    mkdir -p "$backup_dir"
    print_status "info" "Backing up SSH files for $node..."
    
    if [ -f ~/.ssh/id_rsa ]; then
        cp ~/.ssh/id_rsa "$backup_dir/"
    fi
    if [ -f ~/.ssh/id_rsa.pub ]; then
        cp ~/.ssh/id_rsa.pub "$backup_dir/"
    fi
    if [ -f ~/.ssh/authorized_keys ]; then
        cp ~/.ssh/authorized_keys "$backup_dir/"
    fi
    
    check_command "Backup completed for $node" "Backup failed for $node"
}

# Function to restore SSH files
restore_ssh_files() {
    local node=$1
    local backup_dir=$2
    
    if [ -d "$backup_dir" ]; then
        print_status "info" "Restoring SSH files for $node..."
        
        if [ -f "$backup_dir/id_rsa" ]; then
            cp "$backup_dir/id_rsa" ~/.ssh/
        fi
        if [ -f "$backup_dir/id_rsa.pub" ]; then
            cp "$backup_dir/id_rsa.pub" ~/.ssh/
        fi
        if [ -f "$backup_dir/authorized_keys" ]; then
            cp "$backup_dir/authorized_keys" ~/.ssh/
        fi
        
        check_command "Restore completed for $node" "Restore failed for $node"
    else
        print_status "error" "Backup directory not found: $backup_dir"
    fi
}

# Function to check node health
check_node_health() {
    local node=$1
    local ip=$2
    local user=$3
    
    print_status "info" "Checking health of $node ($ip)..."
    
    # Check if node is reachable
    ping -c 1 -W 1 "$ip" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        print_status "error" "$node is not reachable"
        return 1
    fi
    
    # Check SSH port
    nc -z -w 1 "$ip" 22
    if [ $? -ne 0 ]; then
        print_status "error" "SSH port is not open on $node"
        return 1
    fi
    
    # Check disk space
    ssh -i ~/.ssh/id_rsa "$user@$ip" "df -h /" 2>/dev/null
    if [ $? -ne 0 ]; then
        print_status "error" "Cannot check disk space on $node"
        return 1
    fi
    
    print_status "success" "$node health check passed"
    return 0
}

# Function to setup SSH for a single node
setup_node() {
    local node_name=$1
    local node_ip=$2
    local user=$3
    local aws_key=$4
    
    print_status "info" "Setting up SSH for $node_name ($node_ip)"
    
    # Backup existing SSH files
    backup_ssh_files "$node_name"
    
    # Copy public key to target node
    print_status "info" "Copying public key to $node_name..."
    ssh-copy-id -i ~/.ssh/id_rsa.pub -o "IdentityFile ~/.ssh/$aws_key" "$user@$node_ip"
    check_command "Public key copied to $node_name" "Failed to copy public key to $node_name"
    
    # Test SSH connection
    print_status "info" "Testing SSH connection to $node_name..."
    ssh -i ~/.ssh/id_rsa "$user@$node_ip" "echo 'SSH connection successful'" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        print_status "success" "SSH connection to $node_name successful"
        return 0
    else
        print_status "error" "SSH connection to $node_name failed"
        FAILED_NODES+=("$node_name")
        return 1
    fi
}

# Function to setup SSH in parallel
setup_nodes_parallel() {
    local nodes=("$@")
    local max_jobs=4
    local current_jobs=0
    
    for node in "${nodes[@]}"; do
        while [ $current_jobs -ge $max_jobs ]; do
            wait -n
            current_jobs=$((current_jobs - 1))
        done
        
        setup_node "${NODES[$node]}" &
        current_jobs=$((current_jobs + 1))
    done
    
    wait
}

# Function to show interactive menu
show_menu() {
    clear
    echo -e "${YELLOW}=== SSH Setup Menu ===${NC}"
    echo "1. Setup all nodes"
    echo "2. Setup specific node"
    echo "3. Check node health"
    echo "4. Backup SSH files"
    echo "5. Restore SSH files"
    echo "6. Show failed nodes"
    echo "7. Exit"
    echo
    read -p "Enter your choice: " choice
    return $choice
}

# Function to load configuration
load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        print_status "error" "Configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    
    # Load configuration
    eval $(parse_yaml "$CONFIG_FILE")
    
    # Set up logging
    if [ "$logging_enabled" = "true" ]; then
        LOG_FILE="$logging_directory/ssh_setup_$(date +%Y%m%d_%H%M%S).log"
        mkdir -p "$logging_directory"
    fi
    
    # Set up backup
    if [ "$backup_enabled" = "true" ]; then
        BACKUP_DIR="$backup_directory"
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Store node information
    NODES["control"]="$nodes_control_ip"
    NODES["master-1"]="$nodes_masters_0_ip"
    NODES["master-2"]="$nodes_masters_1_ip"
    NODES["master-3"]="$nodes_masters_2_ip"
    NODES["worker-1"]="$nodes_workers_0_ip"
    NODES["worker-2"]="$nodes_workers_1_ip"
}

# Function to parse YAML
parse_yaml() {
    local prefix=$2
    local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
    sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
    awk -F$fs '{
        indent = length($1)/2;
        vname[indent] = $2;
        for (i in vname) {if (i > indent) {delete vname[i]}}
        if (length($3) > 0) {
            vn="";
            for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
            printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
        }
    }'
}

# Main script starts here
echo -e "${YELLOW}=== SSH Setup Script ===${NC}"

# Load configuration
load_config

# Main menu loop
while true; do
    show_menu
    case $? in
        1)
            # Setup all nodes
            print_status "info" "Setting up all nodes..."
            setup_nodes_parallel "${!NODES[@]}"
            ;;
        2)
            # Setup specific node
            echo "Available nodes:"
            for node in "${!NODES[@]}"; do
                echo "- $node"
            done
            read -p "Enter node name: " node_name
            if [ -n "${NODES[$node_name]}" ]; then
                setup_node "$node_name" "${NODES[$node_name]}" "$nodes_control_user" "$aws_key_name"
            else
                print_status "error" "Invalid node name"
            fi
            ;;
        3)
            # Check node health
            for node in "${!NODES[@]}"; do
                check_node_health "$node" "${NODES[$node]}" "$nodes_control_user"
            done
            ;;
        4)
            # Backup SSH files
            for node in "${!NODES[@]}"; do
                backup_ssh_files "$node"
            done
            ;;
        5)
            # Restore SSH files
            echo "Available backups:"
            ls -1 "$BACKUP_DIR" 2>/dev/null
            read -p "Enter backup directory: " backup_dir
            for node in "${!NODES[@]}"; do
                restore_ssh_files "$node" "$BACKUP_DIR/$backup_dir"
            done
            ;;
        6)
            # Show failed nodes
            if [ ${#FAILED_NODES[@]} -eq 0 ]; then
                print_status "info" "No failed nodes"
            else
                print_status "error" "Failed nodes:"
                for node in "${FAILED_NODES[@]}"; do
                    echo "- $node"
                done
            fi
            ;;
        7)
            # Exit
            print_status "info" "Exiting..."
            exit 0
            ;;
        *)
            print_status "error" "Invalid choice"
            ;;
    esac
    
    read -p "Press Enter to continue..."
done 