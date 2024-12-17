#!/bin/bash

# Color definitions
PURPLE='\033[0;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Configuration
HOSTNAME="VPS"
HISTORY_FILE="/home/container/.custom_shell_history"
MAX_HISTORY=1000

# Function to handle cleanup on exit
cleanup() {
    printf "\n${GREEN}Session ended. Goodbye!${NC}\n"
    exit 0
}

# Function to get formatted directory
get_formatted_dir() {
    current_dir="$PWD"
    if [[ "$current_dir" == "/home/container"* ]]; then
        printf "%s" "${current_dir#/home/container}"
        if [ "$current_dir" = "/home/container" ]; then
            printf "/"
        fi
    else
        cd /home/container
        printf "/"
    fi
}

# Function to print the banner
print_banner() {
    printf "\033c"
    printf "${GREEN}╭────────────────────────────────────────────────────────────────────────────────╮${NC}\n"
    printf "${GREEN}│                                                                                │${NC}\n"
    printf "${GREEN}│                             LINUX VPS                                          │${NC}\n"
    printf "${GREEN}│                                                                                │${NC}\n"
    printf "${GREEN}│                           ${RED}© 2021 - 2024 ${PURPLE}@lipey1${GREEN}                                │${NC}\n"
    printf "${GREEN}│                                                                                │${NC}\n"
    printf "${GREEN}╰────────────────────────────────────────────────────────────────────────────────╯${NC}\n\n"
}

print_instructions() {
    printf "${YELLOW}Type 'help' to view a list of available custom commands.${NC}\n\n"
    printf "${GREEN}root@${HOSTNAME}${NC}:${RED}$(get_formatted_dir)${NC}# "
    exec 1>&1  # Força o flush do buffer
}

# Function to print prompt
print_prompt() {
    printf "\n${GREEN}root@${HOSTNAME}${NC}:${RED}$(get_formatted_dir)${NC}# "
}

# Function to save command to history
save_to_history() {
    cmd="$1"
    if [ -n "$cmd" ] && [ "$cmd" != "exit" ]; then
        # Create history file if it doesn't exist
        touch "$HISTORY_FILE" 2>/dev/null || return 0
        printf "%s\n" "$cmd" >> "$HISTORY_FILE" 2>/dev/null || return 0
        # Keep only last MAX_HISTORY lines
        if [ -f "$HISTORY_FILE" ]; then
            tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "$HISTORY_FILE.tmp" 2>/dev/null && \
            mv "$HISTORY_FILE.tmp" "$HISTORY_FILE" 2>/dev/null || return 0
        fi
    fi
}

# Function to reinstall the OS
reinstall() {
    # Source the /etc/os-release file to get OS information
    . /etc/os-release

    printf "\n${GREEN}Reinstalling....${NC}\n"
    
    # Remove everything
    if [ "$ID" = "alpine" ] || [ "$ID" = "chimera" ]; then
        rm -rf / > /dev/null 2>&1
    else
        rm -rf --no-preserve-root / > /dev/null 2>&1
    fi
    
    # Force exit to trigger container restart
    exit 2
}

# Function to print help message
print_help_message() {
    printf "${PURPLE}╭────────────────────────────────────────────────────────────────────────────────╮${NC}\n"
    printf "${PURPLE}│                                                                                │${NC}\n"
    printf "${PURPLE}│                             Available Commands                                 │${NC}\n"
    printf "${PURPLE}│                                                                                │${NC}\n"
    printf "${PURPLE}│                      ${YELLOW}clear, cls${GREEN}         - Clear the screen.                    ${PURPLE}│${NC}\n"
    printf "${PURPLE}│                      ${YELLOW}exit${GREEN}               - Shutdown the server.                 ${PURPLE}│${NC}\n"
    printf "${PURPLE}│                      ${YELLOW}history${GREEN}            - Show command history.                ${PURPLE}│${NC}\n"
    printf "${PURPLE}│                      ${YELLOW}reinstall${GREEN}          - Reinstall the server.                ${PURPLE}│${NC}\n"
    printf "${PURPLE}│                      ${YELLOW}help${GREEN}               - Display this help message.           ${PURPLE}│${NC}\n"
    printf "${PURPLE}│                                                                                │${NC}\n"
    printf "${PURPLE}╰────────────────────────────────────────────────────────────────────────────────╯${NC}\n"
}

# Function to fix package management permissions
fix_permissions() {
    # Create custom directories for apt
    mkdir -p /home/container/apt/{cache,lists,log}
    chmod -R 777 /home/container/apt

    # Remove any existing locks
    rm -f /var/lib/dpkg/lock* /var/lib/apt/lists/lock* /var/cache/apt/archives/lock* 2>/dev/null || true
    rm -f /home/container/apt/lists/lock* /home/container/apt/cache/archives/lock* 2>/dev/null || true
    
    # Set proper permissions for package management directories
    chmod -R 777 /var/lib/dpkg /var/lib/apt /var/cache/apt 2>/dev/null || true
    
    # Create and set permissions for key directories
    mkdir -p /var/lib/dpkg/updates /var/lib/apt/lists/partial /var/cache/apt/archives/partial 2>/dev/null || true
    chmod -R 777 /var/lib/dpkg/updates /var/lib/apt/lists/partial /var/cache/apt/archives/partial 2>/dev/null || true
    
    # Ensure specific files are writable
    touch /var/lib/dpkg/status /var/lib/dpkg/available 2>/dev/null || true
    chmod 666 /var/lib/dpkg/status /var/lib/dpkg/available 2>/dev/null || true

    # Create log directories with proper permissions
    mkdir -p /var/log/apt /var/log/dpkg 2>/dev/null || true
    chmod -R 777 /var/log/apt /var/log/dpkg 2>/dev/null || true
}

# Function to execute command with proper permissions
execute_command() {
    cmd="$1"
    
    # Save command to history
    save_to_history "$cmd"
    
    # Handle special commands
    case "$cmd" in
        "clear"|"cls")
            print_banner
            print_prompt
            return 0
        ;;
        "exit")
            cleanup
        ;;
        "history")
            if [ -f "$HISTORY_FILE" ]; then
                cat "$HISTORY_FILE"
            fi
            print_prompt
            return 0
        ;;
        "reinstall")
            reinstall
        ;;
        "help")
            print_help_message
            print_prompt
            return 0
        ;;
        "sudo"*|"su"*)
            printf "${RED}sudo command is not available. You are already running as root.${NC}\n"
            print_prompt
            return 0
        ;;
        "cd "*)
            # Extract the target directory
            target_dir="${cmd#cd }"
            
            # Try to change to the directory
            if cd "$target_dir" 2>/dev/null; then
                # Check if we're still in /home/container
                if [[ "$PWD" != "/home/container"* ]]; then
                    cd /home/container
                    printf "${RED}Access denied: Cannot navigate outside of /${NC}\n"
                fi
            else
                printf "${RED}Directory not found: $target_dir${NC}\n"
            fi
            print_prompt
            return 0
        ;;
        *)
            # Fix permissions before package management commands
            if [[ "$cmd" == "apt"* || "$cmd" == "apt-get"* || "$cmd" == "dpkg"* ]]; then
                fix_permissions
                # Execute with fakeroot and proper environment
                cmd="fakeroot env APT_CONFIG=/etc/apt/apt.conf.d/99custom $cmd"
            fi
            
            # Execute command
            if ! eval "$cmd" 2> >(grep -v "command not found" >&2); then
                if ! command -v "${cmd%% *}" >/dev/null 2>&1; then
                    printf "${RED}%s: Command not found${NC}\n" "${cmd%% *}"
                fi
            fi
            print_prompt
            return 0
        ;;
    esac
}

# Function to run command prompt
run_prompt() {
    read -r cmd
    execute_command "$cmd"
    print_prompt
}

# Create history file if it doesn't exist
touch "$HISTORY_FILE"

# Set up trap for clean exit
trap cleanup INT TERM

# Print initial banner
print_banner

# Print the initial instructions 
print_instructions

# Ensure we start in /home/container
cd /home/container

# Main command loop
while true; do
    run_prompt
done