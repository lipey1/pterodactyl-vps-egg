#!/bin/bash

# Ensure we're running as root
if [ "$(id -u)" != "0" ]; then
    exec sudo -u root "$0" "$@"
fi

# Sleep for 2 seconds to ensure container is ready
sleep 2

cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')

# Fix permissions for package management
fix_permissions() {
    # Remove any existing locks
    rm -f /var/lib/dpkg/lock* /var/lib/apt/lists/lock* /var/cache/apt/archives/lock* 2>/dev/null || true
    
    # Set proper permissions for package management directories
    chmod -R 777 /var/lib/dpkg /var/lib/apt /var/cache/apt 2>/dev/null || true
    
    # Create and set permissions for key directories
    mkdir -p /var/lib/dpkg/updates /var/lib/apt/lists/partial /var/cache/apt/archives/partial 2>/dev/null || true
    chmod -R 777 /var/lib/dpkg/updates /var/lib/apt/lists/partial /var/cache/apt/archives/partial 2>/dev/null || true
    
    # Ensure specific files are writable
    touch /var/lib/dpkg/status /var/lib/dpkg/available 2>/dev/null || true
    chmod 666 /var/lib/dpkg/status /var/lib/dpkg/available 2>/dev/null || true
}

# Check if already installed by looking for a marker file
if [ ! -e "/home/container/.os_installed" ]; then
    # Fix permissions before installation
    fix_permissions
    
    # Run installation script
    bash "/install.sh" || exit 1
    
    # Create marker file after successful installation
    touch "/home/container/.os_installed"
else
    # Fix permissions on every startup
    fix_permissions
fi

# Run the server
bash "/run.sh"