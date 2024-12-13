#!/bin/bash

# Sleep for 2 seconds to ensure container is ready
sleep 2

cd /home/container
MODIFIED_STARTUP=$(eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))

# Make internal Docker IP address available to processes.
export INTERNAL_IP=$(ip route get 1 | awk '{print $NF;exit}')

# Check if already installed
if [ ! -e "$HOME/.installed" ]; then
    # Configure root access
    chmod 4755 /bin/su
    chmod 4755 /usr/bin/sudo
    echo "root:container" | chpasswd
    
    # Configure sudo without password
    echo "container ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/container
    echo "Defaults !requiretty" >> /etc/sudoers
    chmod 440 /etc/sudoers.d/container
    
    # Give container user proper permissions
    chown -R root:root /
    chmod -R 755 /
    chown -R container:container /home/container
    
    # Mark as installed
    touch "$HOME/.installed"
fi

# Run PRoot with full root access
/usr/bin/proot \
    --rootfs="/" \
    -0 \
    -r / \
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
    -b /tmp \
    -b /var/tmp \
    -b /run \
    -b /var/run \
    /bin/bash "/run.sh"