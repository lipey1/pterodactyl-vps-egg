#!/bin/bash

# Sleep for 2 seconds to ensure container is ready
sleep 2

cd /home/container
MODIFIED_STARTUP=$(eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# Make internal Docker IP address available to processes.
export INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')

# Check if already installed
if [ ! -e "$HOME/.installed" ]; then
    # Configure sudo
    echo "container ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/container
    chmod 440 /etc/sudoers.d/container
    
    # Set root password for su
    echo "root:container" | chpasswd
    
    # Give container user proper permissions
    chown -R container:container /home/container
    
    # Mark as installed
    touch "$HOME/.installed"
fi

# Run PRoot with proper configuration
/usr/bin/proot \
    --rootfs="/" \
    -0 \
    -w "/root" \
    -b /dev \
    -b /sys \
    -b /proc \
    -b /etc/resolv.conf \
    -b /etc/sudoers \
    -b /etc/sudoers.d \
    -b /usr/bin/sudo \
    -b /usr/lib \
    -b /usr/libexec \
    -b /var/run/sudo \
    --link2symlink \
    /bin/bash "/run.sh"