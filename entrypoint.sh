#!/bin/bash

# Sleep for 2 seconds to ensure container is ready
sleep 2

cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')

# Fix permissions for package management
fix_permissions() {
    chmod 755 /var/lib/dpkg 2>/dev/null || true
    chmod 644 /var/lib/dpkg/status 2>/dev/null || true
    chmod 644 /var/lib/dpkg/available 2>/dev/null || true
    chmod -R 755 /var/lib/apt 2>/dev/null || true
    chmod -R 755 /var/cache/apt 2>/dev/null || true
    chmod 755 /var/lib/dpkg/lock-frontend 2>/dev/null || true
    chmod 755 /var/lib/dpkg/lock 2>/dev/null || true
}

# Check if already installed by looking for a marker file
if [ ! -e "/home/container/.os_installed" ]; then
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