#!/bin/bash

# Parse port configuration
parse_ports() {
    local config_file="$HOME/vps.config"
    local port_args=""
    
    while read -r line; do
        case "$line" in
            internalip=*) ;;
            port[0-9]*=*)
                port=${line#*=}
                if [ -n "$port" ]; then port_args=" -p $port:$port$port_args"; fi
            ;;
            port=*)
                port=${line#*=}
                if [ -n "$port" ]; then port_args=" -p $port:$port$port_args"; fi
            ;;
        esac
    done <"$config_file"
}

# Function to fix permissions before starting proot
fix_permissions() {
    # Remove any existing locks
    rm -f "${HOME}/var/lib/dpkg/lock"* "${HOME}/var/lib/apt/lists/lock"* "${HOME}/var/cache/apt/archives/lock"* 2>/dev/null || true
    
    # Set proper permissions for package management directories
    chmod -R 777 "${HOME}/var/lib/dpkg" "${HOME}/var/lib/apt" "${HOME}/var/cache/apt" 2>/dev/null || true
    
    # Create and set permissions for key directories
    mkdir -p "${HOME}/var/lib/dpkg/updates" "${HOME}/var/lib/apt/lists/partial" "${HOME}/var/cache/apt/archives/partial" 2>/dev/null || true
    chmod -R 777 "${HOME}/var/lib/dpkg/updates" "${HOME}/var/lib/apt/lists/partial" "${HOME}/var/cache/apt/archives/partial" 2>/dev/null || true
    
    # Ensure specific files are writable
    touch "${HOME}/var/lib/dpkg/status" "${HOME}/var/lib/dpkg/available" 2>/dev/null || true
    chmod 666 "${HOME}/var/lib/dpkg/status" "${HOME}/var/lib/dpkg/available" 2>/dev/null || true
}

# Execute PRoot environment
exec_proot() {
    local port_args=$(parse_ports)
    
    # Fix permissions before starting PRoot
    fix_permissions
    
    /usr/bin/proot \
    --rootfs="${HOME}" \
    -0 -w "${HOME}" \
    -b /dev -b /sys -b /proc -b /etc/resolv.conf \
    -b /etc/passwd -b /etc/group \
    --link2symlink \
    --kill-on-exit \
    --sysvipc \
    -i 0:0 \
    -E HOME=/ \
    -E TERM=xterm \
    -E LANG=C.UTF-8 \
    -E PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    /bin/sh "/run.sh"
}

exec_proot