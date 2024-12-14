#!/bin/bash

# Sleep for 2 seconds to ensure container is ready
sleep 2

cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')

# Check if already installed by looking for a marker file
if [ ! -e "/home/container/.os_installed" ]; then
    # Run installation script
    bash "/install.sh" || exit 1
    # Create marker file after successful installation
    touch "/home/container/.os_installed"
fi

# Run the server
bash "/run.sh"