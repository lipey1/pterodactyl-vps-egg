#!/bin/bash

# Parse port configuration
parse_ports() {
    local config_file="$HOME/vps.config"
    local port_args=""
    
    # Create config file if it doesn't exist
    if [ ! -f "$config_file" ]; then
        touch "$config_file"
    fi
    
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
    
    echo "$port_args"
}

# Execute PRoot environment
exec_proot() {
    local port_args=$(parse_ports)
    
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
    $port_args \
    /bin/sh -c "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin exec /run.sh"
}

# Execute with root privileges by default
exec_proot
