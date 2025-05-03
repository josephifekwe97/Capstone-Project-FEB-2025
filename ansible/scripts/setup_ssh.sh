#!/bin/bash

# Add at the beginning of the script, after the shebang
trap 'handle_interrupt' INT

# Configuration
CONFIG_FILE="config.yml"
TMP_KEY_FILE="$HOME/.ssh/tmp_ssh_key.pem"  # Changed to user's home directory
BACKUP_DIR="$HOME/.ssh/backup"
LOG_FILE="$HOME/.ssh/logs/ssh_setup_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored messages and log them
print_status() {
  local type="$1"
  local message="$2"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  
  case "$type" in
    info) echo -e "${BLUE}[INFO]${NC} $message" ;;
    success) echo -e "${GREEN}[SUCCESS]${NC} $message" ;;
    warning) echo -e "${YELLOW}[WARNING]${NC} $message" ;;
    error) echo -e "${RED}[ERROR]${NC} $message" ;;
    debug) echo -e "${BLUE}[DEBUG]${NC} $message" ;;
    *) echo "[UNKNOWN] $message" ;;
  esac
  
  # Log the message
  mkdir -p "$(dirname "$LOG_FILE")"
  echo "[$timestamp] [$type] $message" >> "$LOG_FILE"
}

# Function to handle interrupts
handle_interrupt() {
  echo -e "\n${YELLOW}Interrupt received. Cleaning up...${NC}"
  
  # Clean up temporary files
  if [ -f "$TMP_KEY_FILE" ]; then
    rm -f "$TMP_KEY_FILE"
    print_status "info" "Temporary key file deleted"
  fi
  
  if [ -f "${TMP_KEY_FILE}.pub" ]; then
    rm -f "${TMP_KEY_FILE}.pub"
    print_status "info" "Temporary public key file deleted"
  fi
  
  print_status "info" "Cleanup complete. Exiting..."
  exit 1
}

# Function to backup SSH key
backup_ssh_key() {
  mkdir -p "$BACKUP_DIR"
  local backup_file="$BACKUP_DIR/ssh_key_$(date +%Y%m%d_%H%M%S).pem"
  cp "$TMP_KEY_FILE" "$backup_file"
  chmod 600 "$backup_file"
  print_status "info" "SSH key backed up to: $backup_file"
}

# Function to select SSH key file
select_ssh_key() {
  local key_path=""
  local max_attempts=3
  local attempt=0

  while [ $attempt -lt $max_attempts ]; do
    echo -e "\n${YELLOW}=== SSH Key Selection ==="
    echo "1. Enter path to existing key file"
    echo "2. Enter key content manually"
    echo "3. Exit"
    echo -e "${NC}"
    
    read -p "Enter your choice (1-3): " choice
    
    case "$choice" in
      1)
        read -p "Enter the full path to your SSH key file: " key_path
        if [ -f "$key_path" ]; then
          # Copy the key to temporary location
          cp "$key_path" "$TMP_KEY_FILE"
          chmod 600 "$TMP_KEY_FILE"
          print_status "info" "SSH key copied from: $key_path"
          return 0
        else
          print_status "error" "Key file not found: $key_path"
          attempt=$((attempt + 1))
        fi
        ;;
      2)
        # Use existing manual input method
        if prompt_for_ssh_key; then
          return 0
        else
          attempt=$((attempt + 1))
        fi
        ;;
      3)
        print_status "info" "Exiting..."
        exit 0
        ;;
      *)
        print_status "error" "Invalid choice. Please enter 1, 2, or 3."
        attempt=$((attempt + 1))
        ;;
    esac
  done
  
  print_status "error" "Maximum attempts reached. Exiting..."
  exit 1
}

# Function to prompt for SSH key
prompt_for_ssh_key() {
  echo
  echo "=== SSH Key Input ==="
  echo "Paste your PRIVATE key below (e.g., contents of your .pem file), then press Ctrl+D when done:"
  
  # Create temporary file with proper permissions
  touch "$TMP_KEY_FILE"
  chmod 600 "$TMP_KEY_FILE"
  
  # Read input and write to file
  cat > "$TMP_KEY_FILE"
  
  if [ -s "$TMP_KEY_FILE" ]; then
    print_status "info" "SSH key saved to temporary location: $TMP_KEY_FILE"
    backup_ssh_key
    return 0
  else
    print_status "error" "No key content provided"
    rm -f "$TMP_KEY_FILE"
    return 1
  fi
}

# Function to copy public key to target node
copy_public_key() {
  local name="$1"
  local ip="$2"
  local user="$3"
  local max_retries=3
  local retry_count=0
  local timeout=30

  print_status "info" "Setting up SSH keys on node: $name"
  print_status "info" "Using IP: $ip"
  print_status "info" "Using username: $user"
  
  # Generate public key from private key if it doesn't exist
  if [ ! -f "${TMP_KEY_FILE}.pub" ]; then
    ssh-keygen -y -f "$TMP_KEY_FILE" > "${TMP_KEY_FILE}.pub"
    chmod 644 "${TMP_KEY_FILE}.pub"
  fi

  while [ $retry_count -lt $max_retries ]; do
    print_status "info" "Attempt $((retry_count + 1)) of $max_retries"
    
    # Create .ssh directory and set permissions
    if timeout $timeout ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout -i "$TMP_KEY_FILE" "$user@$ip" "mkdir -p ~/.ssh && chmod 700 ~/.ssh" >/dev/null 2>&1; then
      # Copy private key
      if timeout $timeout scp -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout -i "$TMP_KEY_FILE" "$TMP_KEY_FILE" "$user@$ip:~/.ssh/id_rsa" >/dev/null 2>&1; then
        # Copy public key
        if timeout $timeout scp -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout -i "$TMP_KEY_FILE" "${TMP_KEY_FILE}.pub" "$user@$ip:~/.ssh/id_rsa.pub" >/dev/null 2>&1; then
          # Set proper permissions
          if timeout $timeout ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout -i "$TMP_KEY_FILE" "$user@$ip" "chmod 600 ~/.ssh/id_rsa ~/.ssh/id_rsa.pub" >/dev/null 2>&1; then
            # Add public key to authorized_keys
            if timeout $timeout ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout -i "$TMP_KEY_FILE" "$user@$ip" "cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" >/dev/null 2>&1; then
              print_status "success" "SSH keys setup on $name successful"
              return 0
            fi
          fi
        fi
      fi
    fi
    
    print_status "warning" "Key setup attempt $((retry_count + 1)) failed for $name"
    print_status "info" "Retrying in 5 seconds..."
    retry_count=$((retry_count + 1))
    sleep 5
  done
  
  print_status "error" "Failed to setup SSH keys on $name after $max_retries attempts"
  return 1
}

# Function to test SSH between nodes
test_node_connectivity() {
  local source_name="$1"
  local source_ip="$2"
  local source_user="$3"
  local target_name="$4"
  local target_ip="$5"
  local target_user="$6"
  local max_retries=3
  local retry_count=0
  local timeout=15  # Reduced from 30 to 15 seconds

  print_status "info" "Testing SSH from $source_name to $target_name"
  
  while [ $retry_count -lt $max_retries ]; do
    print_status "info" "Attempt $((retry_count + 1)) of $max_retries"
    
    # Test SSH connection using the key on the source node
    if timeout $timeout ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout -i "$TMP_KEY_FILE" "$source_user@$source_ip" "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout -i ~/.ssh/id_rsa $target_user@$target_ip 'echo SSH test successful'" >/dev/null 2>&1; then
      print_status "success" "SSH test from $source_name to $target_name successful"
      return 0
    else
      print_status "warning" "SSH test attempt $((retry_count + 1)) failed from $source_name to $target_name"
      print_status "info" "Retrying in 2 seconds..."  # Reduced from 5 to 2 seconds
      retry_count=$((retry_count + 1))
      sleep 2
    fi
  done
  
  print_status "error" "SSH test from $source_name to $target_name failed after $max_retries attempts"
  return 1
}

# Function to setup SSH for a node with timeout and retry
setup_ssh() {
  local name="$1"
  local ip="$2"
  local user="$3"
  local max_retries=3
  local retry_count=0
  local timeout=30

  # Clean up the values
  name=$(echo "$name" | tr -d '"' | xargs)
  ip=$(echo "$ip" | tr -d '"' | xargs)
  user=$(echo "$user" | tr -d '"' | xargs)

  # Validate the values
  if [[ -z "$ip" || -z "$user" ]]; then
    print_status "error" "Invalid node configuration for $name - Missing IP or user"
    return 1
  fi

  print_status "info" "Setting up SSH for node: $name"
  print_status "info" "Using IP: $ip"
  print_status "info" "Using username: $user"
  print_status "info" "Using key file: $TMP_KEY_FILE"
  
  while [ $retry_count -lt $max_retries ]; do
    print_status "info" "Attempt $((retry_count + 1)) of $max_retries"
    
    # Test SSH connection with timeout and verbose output
    if timeout $timeout ssh -v -o StrictHostKeyChecking=no -o ConnectTimeout=$timeout -i "$TMP_KEY_FILE" "$user@$ip" "echo SSH to $name successful" >/dev/null 2>&1; then
      print_status "success" "SSH setup for $name successful"
      
      # Copy public key to the node
      if copy_public_key "$name" "$ip" "$user"; then
        return 0
      else
        return 1
      fi
    else
      print_status "warning" "SSH attempt $((retry_count + 1)) failed for $name"
      print_status "info" "Retrying in 5 seconds..."
      retry_count=$((retry_count + 1))
      sleep 5
    fi
  done
  
  print_status "error" "SSH setup for $name failed after $max_retries attempts"
  print_status "error" "Last attempt details:"
  print_status "error" "  Node: $name"
  print_status "error" "  IP: $ip"
  print_status "error" "  User: $user"
  print_status "error" "  Key: $TMP_KEY_FILE"
  return 1
}

# Function to get node list from config
get_node_list() {
  local section="$1"
  local nodes_var="$2"
  local -a nodes=()
  
  print_status "debug" "Looking for nodes in section: $section"
  
  # Extract node names using yq (YAML processor)
  if command -v yq &> /dev/null; then
    while IFS= read -r node_name; do
      if [[ -n "$node_name" ]]; then
        nodes+=("$node_name")
        print_status "debug" "Found node: $node_name"
      fi
    done < <(yq ".nodes.$section[].name" "$CONFIG_FILE")
  else
    # Fallback to grep/awk if yq is not available
    while IFS= read -r node_name; do
      if [[ -n "$node_name" ]]; then
        nodes+=("$node_name")
        print_status "debug" "Found node: $node_name"
      fi
    done < <(grep -A 3 "^[[:space:]]*$section:" "$CONFIG_FILE" | 
             grep "^[[:space:]]*-[[:space:]]*name:" | 
             awk '{print $2}' | 
             tr -d '[:space:]')
  fi
  
  # Assign the array to the named variable
  eval "$nodes_var=(\"\${nodes[@]}\")"
  print_status "debug" "Found ${#nodes[@]} nodes in $section section: ${nodes[*]}"
}

# Function to get node info from config
get_node_info() {
  local section="$1"
  local name="$2"
  local ip_var="$3"
  local user_var="$4"
  local node_ip=""
  local node_user=""
  
  # Extract node information using yq (YAML processor)
  if command -v yq &> /dev/null; then
    # Remove quotes from node name for yq query
    name=$(echo "$name" | tr -d '"')
    
    # Use yq to extract IP and user, redirecting debug output to stderr
    node_ip=$(yq -r ".nodes.$section[] | select(.name == \"$name\") | .ip" "$CONFIG_FILE" 2>/dev/null)
    node_user=$(yq -r ".nodes.$section[] | select(.name == \"$name\") | .user" "$CONFIG_FILE" 2>/dev/null)
    
    # Clean up the values
    node_ip=$(echo "$node_ip" | tr -d '[:space:]')
    node_user=$(echo "$node_user" | tr -d '[:space:]')
    
    # Print debug info to stderr
    print_status "debug" "Found node details for $name:" >&2
    print_status "debug" "  IP: $node_ip" >&2
    print_status "debug" "  User: $node_user" >&2
  else
    # Fallback to grep/awk if yq is not available
    print_status "debug" "Using grep/awk fallback for $name" >&2
    local node_block=$(grep -A 5 "^[[:space:]]*$section:" "$CONFIG_FILE" | 
                      grep -A 3 "^[[:space:]]*-[[:space:]]*name:[[:space:]]*$name[[:space:]]*$" | 
                      grep -v "^[[:space:]]*-[[:space:]]*name:")
    
    node_ip=$(echo "$node_block" | grep "^[[:space:]]*ip:" | awk '{print $2}' | tr -d '[:space:]')
    node_user=$(echo "$node_block" | grep "^[[:space:]]*user:" | awk '{print $2}' | tr -d '[:space:]')
    
    print_status "debug" "Fallback results:" >&2
    print_status "debug" "  IP: $node_ip" >&2
    print_status "debug" "  User: $node_user" >&2
  fi
  
  # Return only the values, no debug text
  echo "$node_ip"
  echo "$node_user"
}

# Function to get control node details
get_control_node_details() {
  local name_var="$1"
  local ip_var="$2"
  local user_var="$3"
  local name=""
  local ip=""
  local user=""
  
  # Read the config file line by line
  local in_nodes=false
  local in_section=false
  while IFS= read -r line; do
    # Remove any carriage returns
    line=$(echo "$line" | tr -d '\r')
    
    # Check if we're entering the nodes section
    if [[ "$line" =~ ^[[:space:]]*nodes:[[:space:]]*$ ]]; then
      in_nodes=true
      continue
    fi
    
    # If we're in the nodes section
    if [[ "$in_nodes" == true ]]; then
      # Check if we're entering the control section
      if [[ "$line" =~ ^[[:space:]]*control:[[:space:]]*$ ]]; then
        in_section=true
        continue
      fi
      
      # If we're in the section, look for fields
      if [[ "$in_section" == true ]]; then
        if [[ "$line" =~ ^[[:space:]]*name:[[:space:]]*(.*)$ ]]; then
          name=$(echo "${BASH_REMATCH[1]}" | tr -d '[:space:]' | tr -d '\r')
        elif [[ "$line" =~ ^[[:space:]]*ip:[[:space:]]*(.*)$ ]]; then
          ip=$(echo "${BASH_REMATCH[1]}" | tr -d '[:space:]' | tr -d '\r')
        elif [[ "$line" =~ ^[[:space:]]*user:[[:space:]]*(.*)$ ]]; then
          user=$(echo "${BASH_REMATCH[1]}" | tr -d '[:space:]' | tr -d '\r')
        elif [[ "$line" =~ ^[[:space:]]*[^[:space:]] ]]; then
          # Found a new section, exit
          break
        fi
      fi
    fi
  done < "$CONFIG_FILE"
  
  # Assign the values to the named variables
  eval "$name_var=\"$name\""
  eval "$ip_var=\"$ip\""
  eval "$user_var=\"$user\""
}

# Function to monitor nodes
monitor_nodes() {
  local refresh_interval=5  # seconds between updates
  local monitoring=true
  
  # Function to get node metrics
  get_node_metrics() {
    local ip="$1"
    local user="$2"
    local name="$3"
    
    # Get system metrics
    local metrics
    metrics=$(timeout 5 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$TMP_KEY_FILE" "$user@$ip" "
      echo \"CPU: \$(top -bn1 | grep 'Cpu(s)' | awk '{print \$2}')%\"
      echo \"Memory: \$(free -m | awk 'NR==2{printf \"%.2f%%\", \$3*100/\$2}') used\"
      echo \"Disk: \$(df -h / | awk 'NR==2{print \$5}') used\"
      echo \"Uptime: \$(uptime -p)\"
      echo \"Load: \$(uptime | awk -F'[a-z]:' '{print \$2}')\"
    " 2>/dev/null)
    
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}Node: $name ($ip)${NC}"
      echo "$metrics" | while read -r line; do
        echo "  $line"
      done
      echo
    else
      echo -e "${RED}Node: $name ($ip) - Offline${NC}\n"
    fi
  }
  
  # Function to check connectivity between nodes
  check_connectivity() {
    local source_ip="$1"
    local source_user="$2"
    local target_ip="$3"
    local target_user="$4"
    
    if timeout 5 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$TMP_KEY_FILE" "$source_user@$source_ip" \
       "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i ~/.ssh/id_rsa $target_user@$target_ip 'echo connected'" >/dev/null 2>&1; then
      echo -e "${GREEN}✓${NC}"
    else
      echo -e "${RED}✗${NC}"
    fi
  }
  
  # Function to display connectivity matrix
  show_connectivity_matrix() {
    local nodes=()
    local ips=()
    local users=()
    
    # Get control node details
    local control_name control_ip control_user
    get_control_node_details control_name control_ip control_user
    if [[ -n "$control_name" ]]; then
      nodes+=("$control_name")
      ips+=("$control_ip")
      users+=("$control_user")
    fi
    
    # Get master nodes
    local master_nodes=()
    get_node_list "masters" master_nodes
    for name in "${master_nodes[@]}"; do
      node_info=$(get_node_info "masters" "$name" "node_ip" "node_user")
      node_ip=$(echo "$node_info" | head -n1)
      node_user=$(echo "$node_info" | tail -n1)
      if [[ -n "$node_ip" ]]; then
        nodes+=("$name")
        ips+=("$node_ip")
        users+=("$node_user")
      fi
    done
    
    # Get worker nodes
    local worker_nodes=()
    get_node_list "workers" worker_nodes
    for name in "${worker_nodes[@]}"; do
      node_info=$(get_node_info "workers" "$name" "node_ip" "node_user")
      node_ip=$(echo "$node_info" | head -n1)
      node_user=$(echo "$node_info" | tail -n1)
      if [[ -n "$node_ip" ]]; then
        nodes+=("$name")
        ips+=("$node_ip")
        users+=("$node_user")
      fi
    done
    
    # Display matrix header
    echo -e "\n${YELLOW}=== Connectivity Matrix ===${NC}"
    printf "%-15s" ""
    for node in "${nodes[@]}"; do
      printf "%-10s" "$node"
    done
    echo
    
    # Display matrix rows
    for i in "${!nodes[@]}"; do
      printf "%-15s" "${nodes[$i]}"
      for j in "${!nodes[@]}"; do
        if [ $i -eq $j ]; then
          printf "%-10s" "-"
        else
          check_connectivity "${ips[$i]}" "${users[$i]}" "${ips[$j]}" "${users[$j]}"
        fi
      done
      echo
    done
  }
  
  # Main monitoring loop
  while $monitoring; do
    clear
    echo -e "${YELLOW}=== Node Monitoring (Press 'q' to quit) ===${NC}\n"
    
    # Get control node metrics
    local control_name control_ip control_user
    get_control_node_details control_name control_ip control_user
    if [[ -n "$control_name" ]]; then
      get_node_metrics "$control_ip" "$control_user" "$control_name"
    fi
    
    # Get master nodes metrics
    local master_nodes=()
    get_node_list "masters" master_nodes
    for name in "${master_nodes[@]}"; do
      node_info=$(get_node_info "masters" "$name" "node_ip" "node_user")
      node_ip=$(echo "$node_info" | head -n1)
      node_user=$(echo "$node_info" | tail -n1)
      if [[ -n "$node_ip" ]]; then
        get_node_metrics "$node_ip" "$node_user" "$name"
      fi
    done
    
    # Get worker nodes metrics
    local worker_nodes=()
    get_node_list "workers" worker_nodes
    for name in "${worker_nodes[@]}"; do
      node_info=$(get_node_info "workers" "$name" "node_ip" "node_user")
      node_ip=$(echo "$node_info" | head -n1)
      node_user=$(echo "$node_info" | tail -n1)
      if [[ -n "$node_ip" ]]; then
        get_node_metrics "$node_ip" "$node_user" "$name"
      fi
    done
    
    # Show connectivity matrix
    show_connectivity_matrix
    
    # Check for quit command
    read -t $refresh_interval -n 1 -s input
    if [[ "$input" == "q" ]]; then
      monitoring=false
    fi
  done
}

# Function to show menu
show_menu() {
  clear
  echo -e "${YELLOW}=== SSH Setup Menu ===${NC}"
  echo "1. Setup all nodes"
  echo "2. Setup specific node"
  echo "3. Show failed nodes"
  echo "4. View logs"
  echo "5. Show node status"
  echo "6. Monitor nodes"
  echo "7. Cleanup temporary files"
  echo "8. Exit"
  echo
  read -p "Enter your choice (1-8): " choice
  
  # Validate input
  case "$choice" in
    1|2|3|4|5|6|7|8)
      echo "$choice"
      return 0
      ;;
    *)
      print_status "error" "Invalid choice. Please enter a number between 1 and 8."
      return 1
      ;;
  esac
}

# Function to show node status
show_node_status() {
  echo -e "\n${YELLOW}=== Node Status ===${NC}"
  
  # Check control node
  local control_name control_ip control_user
  get_control_node_details control_name control_ip control_user
  
  if [[ -n "$control_name" && -n "$control_ip" && -n "$control_user" ]]; then
    if timeout 5 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$TMP_KEY_FILE" "$control_user@$control_ip" "echo 'Control node is up'" >/dev/null 2>&1; then
      echo -e "${GREEN}Control Node:${NC} $control_name ($control_ip) - Online"
    else
      echo -e "${RED}Control Node:${NC} $control_name ($control_ip) - Offline"
    fi
  fi
  
  # Check master nodes
  local master_nodes=()
  get_node_list "masters" master_nodes
  
  for name in "${master_nodes[@]}"; do
    node_info=$(get_node_info "masters" "$name" "node_ip" "node_user")
    node_ip=$(echo "$node_info" | head -n1)
    node_user=$(echo "$node_info" | tail -n1)
    
    if [[ -n "$node_ip" && -n "$node_user" ]]; then
      if timeout 5 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$TMP_KEY_FILE" "$node_user@$node_ip" "echo 'Master node is up'" >/dev/null 2>&1; then
        echo -e "${GREEN}Master Node:${NC} $name ($node_ip) - Online"
      else
        echo -e "${RED}Master Node:${NC} $name ($node_ip) - Offline"
      fi
    fi
  done
  
  # Check worker nodes
  local worker_nodes=()
  get_node_list "workers" worker_nodes
  
  for name in "${worker_nodes[@]}"; do
    node_info=$(get_node_info "workers" "$name" "node_ip" "node_user")
    node_ip=$(echo "$node_info" | head -n1)
    node_user=$(echo "$node_info" | tail -n1)
    
    if [[ -n "$node_ip" && -n "$node_user" ]]; then
      if timeout 5 ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i "$TMP_KEY_FILE" "$node_user@$node_ip" "echo 'Worker node is up'" >/dev/null 2>&1; then
        echo -e "${GREEN}Worker Node:${NC} $name ($node_ip) - Online"
      else
        echo -e "${RED}Worker Node:${NC} $name ($node_ip) - Offline"
      fi
    fi
  done
  
  read -p "Press Enter to continue..."
}

# Function to cleanup temporary files
cleanup_temporary_files() {
  echo -e "\n${YELLOW}=== Cleanup Temporary Files ===${NC}"
  
  if [ -f "$TMP_KEY_FILE" ]; then
    rm -f "$TMP_KEY_FILE"
    print_status "info" "Temporary key file deleted"
  else
    print_status "info" "No temporary key file found"
  fi
  
  if [ -f "${TMP_KEY_FILE}.pub" ]; then
    rm -f "${TMP_KEY_FILE}.pub"
    print_status "info" "Temporary public key file deleted"
  else
    print_status "info" "No temporary public key file found"
  fi
  
  read -p "Press Enter to continue..."
}

# Function to setup all nodes
setup_all_nodes() {
  local success_count=0
  local total_nodes=0
  local connectivity_success=0
  local total_connections=0
  
  # Setup control node
  local control_name control_ip control_user
  get_control_node_details control_name control_ip control_user
  
  if [[ -n "$control_name" && -n "$control_ip" && -n "$control_user" ]]; then
    if setup_ssh "$control_name" "$control_ip" "$control_user"; then
      success_count=$((success_count + 1))
    fi
    total_nodes=$((total_nodes + 1))
  else
    print_status "error" "Invalid control node configuration"
  fi
  
  # Setup master nodes
  local master_nodes=()
  get_node_list "masters" master_nodes
  
  print_status "debug" "Processing ${#master_nodes[@]} master nodes"
  for name in "${master_nodes[@]}"; do
    if [[ -n "$name" ]]; then
      print_status "debug" "Setting up master node: $name"
      local node_info
      node_info=$(get_node_info "masters" "$name" "node_ip" "node_user")
      local node_ip=$(echo "$node_info" | head -n1)
      local node_user=$(echo "$node_info" | tail -n1)
      
      if [[ -n "$node_ip" && -n "$node_user" ]]; then
        if setup_ssh "$name" "$node_ip" "$node_user"; then
          success_count=$((success_count + 1))
        fi
        total_nodes=$((total_nodes + 1))
      else
        print_status "error" "Invalid configuration for master node: $name"
      fi
    fi
  done
  
  # Setup worker nodes
  local worker_nodes=()
  get_node_list "workers" worker_nodes
  
  print_status "debug" "Processing ${#worker_nodes[@]} worker nodes"
  for name in "${worker_nodes[@]}"; do
    if [[ -n "$name" ]]; then
      print_status "debug" "Setting up worker node: $name"
      local node_info
      node_info=$(get_node_info "workers" "$name" "node_ip" "node_user")
      local node_ip=$(echo "$node_info" | head -n1)
      local node_user=$(echo "$node_info" | tail -n1)
      
      if [[ -n "$node_ip" && -n "$node_user" ]]; then
        if setup_ssh "$name" "$node_ip" "$node_user"; then
          success_count=$((success_count + 1))
        fi
        total_nodes=$((total_nodes + 1))
      else
        print_status "error" "Invalid configuration for worker node: $name"
      fi
    fi
  done

  # Test connectivity between all nodes
  print_status "info" "Testing connectivity between all nodes..."
  
  # Test from control node to all other nodes
  for name in "${master_nodes[@]}"; do
    node_info=$(get_node_info "masters" "$name" "node_ip" "node_user")
    node_ip=$(echo "$node_info" | head -n1)
    node_user=$(echo "$node_info" | tail -n1)
    if test_node_connectivity "$control_name" "$control_ip" "$control_user" "$name" "$node_ip" "$node_user"; then
      connectivity_success=$((connectivity_success + 1))
    fi
    total_connections=$((total_connections + 1))
  done
  
  for name in "${worker_nodes[@]}"; do
    node_info=$(get_node_info "workers" "$name" "node_ip" "node_user")
    node_ip=$(echo "$node_info" | head -n1)
    node_user=$(echo "$node_info" | tail -n1)
    if test_node_connectivity "$control_name" "$control_ip" "$control_user" "$name" "$node_ip" "$node_user"; then
      connectivity_success=$((connectivity_success + 1))
    fi
    total_connections=$((total_connections + 1))
  done
  
  # Test between master nodes
  for source_name in "${master_nodes[@]}"; do
    source_info=$(get_node_info "masters" "$source_name" "source_ip" "source_user")
    source_ip=$(echo "$source_info" | head -n1)
    source_user=$(echo "$source_info" | tail -n1)
    
    for target_name in "${master_nodes[@]}"; do
      if [[ "$source_name" != "$target_name" ]]; then
        target_info=$(get_node_info "masters" "$target_name" "target_ip" "target_user")
        target_ip=$(echo "$target_info" | head -n1)
        target_user=$(echo "$target_info" | tail -n1)
        if test_node_connectivity "$source_name" "$source_ip" "$source_user" "$target_name" "$target_ip" "$target_user"; then
          connectivity_success=$((connectivity_success + 1))
        fi
        total_connections=$((total_connections + 1))
      fi
    done
  done
  
  # Test between worker nodes
  for source_name in "${worker_nodes[@]}"; do
    source_info=$(get_node_info "workers" "$source_name" "source_ip" "source_user")
    source_ip=$(echo "$source_info" | head -n1)
    source_user=$(echo "$source_info" | tail -n1)
    
    for target_name in "${worker_nodes[@]}"; do
      if [[ "$source_name" != "$target_name" ]]; then
        target_info=$(get_node_info "workers" "$target_name" "target_ip" "target_user")
        target_ip=$(echo "$target_info" | head -n1)
        target_user=$(echo "$target_info" | tail -n1)
        if test_node_connectivity "$source_name" "$source_ip" "$source_user" "$target_name" "$target_ip" "$target_user"; then
          connectivity_success=$((connectivity_success + 1))
        fi
        total_connections=$((total_connections + 1))
      fi
    done
  done
  
  # Print summary
  echo -e "\n${YELLOW}=== Setup Summary ===${NC}"
  echo -e "${GREEN}Node Setup:${NC} $success_count/$total_nodes nodes successfully configured"
  echo -e "${GREEN}Connectivity:${NC} $connectivity_success/$total_connections connections successful"
  echo -e "${GREEN}Status:${NC} All nodes can now communicate with each other"
  
  print_status "info" "Completed processing all nodes"
}

# Function to setup specific node
setup_specific_node() {
  echo "Available nodes:"
  echo "1. Control Node"
  
  # List master nodes
  local master_nodes=()
  get_node_list "masters" master_nodes
  for name in "${master_nodes[@]}"; do
    echo "$name"
  done
  
  # List worker nodes
  local worker_nodes=()
  get_node_list "workers" worker_nodes
  for name in "${worker_nodes[@]}"; do
    echo "$name"
  done
  
  read -p "Enter node name: " node_name
  
  # Find node in config
  if grep -q "$node_name" "$CONFIG_FILE"; then
    local node_ip node_user
    if [[ "$node_name" == "$control_name" ]]; then
      node_ip=$control_ip
      node_user=$control_user
    else
      if [[ " ${master_nodes[@]} " =~ " ${node_name} " ]]; then
        get_node_info "masters" "$node_name" node_ip node_user
      else
        get_node_info "workers" "$node_name" node_ip node_user
      fi
    fi
    
    if [[ -n "$node_ip" && -n "$node_user" ]]; then
      if prompt_for_ssh_key; then
        setup_ssh "$node_name" "$node_ip" "$node_user"
        rm -f "$TMP_KEY_FILE"
        print_status "info" "Temporary key file deleted"
      fi
    else
      print_status "error" "Invalid node configuration for $node_name"
    fi
  else
    print_status "error" "Node $node_name not found in config"
  fi
}

# Main script starts here
echo -e "${YELLOW}=== SSH Setup Script ===${NC}"

# Create necessary directories
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$TMP_KEY_FILE")"

# Main menu loop
while true; do
  if show_menu; then
    case "$choice" in
      1)
        # Setup all nodes
        if ! select_ssh_key; then
          read -p "Press Enter to continue..."
          continue
        fi
        
        print_status "info" "Setting up all nodes..."
        setup_all_nodes
        
        rm -f "$TMP_KEY_FILE"
        print_status "info" "Temporary key file deleted"
        read -p "Press Enter to continue..."
        ;;
        
      2)
        # Setup specific node
        setup_specific_node
        read -p "Press Enter to continue..."
        ;;
        
      3)
        # Show failed nodes from log
        if [ -f "$LOG_FILE" ]; then
          grep "ERROR" "$LOG_FILE" | grep "SSH setup for" | sort | uniq
        else
          print_status "info" "No log file found"
        fi
        read -p "Press Enter to continue..."
        ;;
        
      4)
        # View logs
        if [ -f "$LOG_FILE" ]; then
          less "$LOG_FILE"
        else
          print_status "info" "No log file found"
        fi
        read -p "Press Enter to continue..."
        ;;
        
      5)
        # Show node status
        show_node_status
        ;;
        
      6)
        # Monitor nodes
        if [ -f "$TMP_KEY_FILE" ]; then
          monitor_nodes
        else
          print_status "error" "No SSH key found. Please setup nodes first."
          read -p "Press Enter to continue..."
        fi
        ;;
        
      7)
        # Cleanup temporary files
        cleanup_temporary_files
        ;;
        
      8)
        print_status "info" "Exiting..."
        exit 0
        ;;
    esac
  else
    read -p "Press Enter to continue..."
  fi
done 