#!/bin/bash
# configure-tun.sh

# Only runs if tun0 exists
if ip link show tun0 > /dev/null 2>&1; then
    echo "Configuring tun0..."
    # Set the address as requested in 2.2
    ip addr add 172.16.2.1/28 dev tun0
    
    # Bring the interface UP
    ip link set tun0 up
    
    echo "Configuration done."
    ip addr show tun0
else
    echo "Error: tun0 interface does not exist yet."
fi
