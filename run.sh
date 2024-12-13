#!/bin/bash

# Color definitions
PURPLE='\033[0;35m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Configuration
HOSTNAME="MyVPS"
HISTORY_FILE="/root/.custom_shell_history"
MAX_HISTORY=1000

# Function to handle cleanup on exit
cleanup() {
    printf "\n${GREEN}Session ended. Goodbye!${NC}\n"
    exit 0
}

# Function to get formatted directory
get_formatted_dir() {
    printf "%s" "$PWD"
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
    printf "${GREEN}╰────────────────────────────────────────────────────────────────────────────────╯${NC}\n"
    printf "                                                                                               \n"
}

print_instructions() {
    printf "${YELLOW}Type 'help' to view a list of available custom commands.${NC}\n\n"
}

# Function to print prompt
print_prompt() {
    printf "\n${GREEN}root@${HOSTNAME}${NC}:${RED}$(get_formatted_dir)${NC}# "
}

# Function to save command to history
save_to_history() {
    cmd="$1"
    if [ -n "$cmd" ] && [ "$cmd" != "exit" ]; then
        printf "%s\n" "$cmd" >> "$HISTORY_FILE"
        # Keep only last MAX_HISTORY lines
        if [ -f "$HISTORY_FILE" ]; then
            tail -n "$MAX_HISTORY" "$HISTORY_FILE" > "$HISTORY_FILE.tmp"
            mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
        fi
    fi
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
    printf "${PURPLE}│                      ${YELLOW}help${GREEN}               - Display this help message.           ${PURPLE}│${NC}\n"
    printf "${PURPLE}│                                                                                │${NC}\n"
    printf "${PURPLE}╰────────────────────────────────────────────────────────────────────────────────╯${NC}\n"
}

# Function to handle command execution
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
        "help")
            print_help_message
            print_prompt
            return 0
        ;;
        *)
            eval "$cmd"
            print_prompt
            return 0
        ;;
    esac
}

# Function to run command prompt
run_prompt() {
    read -r cmd
    execute_command "$cmd"
}

# Create history file if it doesn't exist
touch "$HISTORY_FILE"

# Set up trap for clean exit
trap cleanup INT TERM

# Print initial banner
print_banner

# Print the initial instructions 
print_instructions

# Print initial command
printf "${GREEN}root@${HOSTNAME}${NC}:${RED}$(get_formatted_dir)${NC}# "

# Main command loop
while true; do
    run_prompt
done