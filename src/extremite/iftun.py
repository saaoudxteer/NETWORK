import os
import fcntl
import struct
import subprocess

# Constants from linux/if_tun.h
TUNSETIFF = 0x400454ca
IFF_TUN   = 0x0001
IFF_NO_PI = 0x1000 # Warning: If you remove this, you get extra 4 bytes header!

def tun_alloc(dev_name="tun0"):
    """
    Creates a TUN interface.
    Returns: file descriptor (int) for the interface.
    """
    # Open the clone device
    try:
        tun_fd = os.open("/dev/net/tun", os.O_RDWR)
    except FileNotFoundError:
        print("Error: /dev/net/tun not found. Are you on Linux?")
        exit(1)
    except PermissionError:
        print("Error: Permission denied. Did you run with sudo?")
        exit(1)

    # Prepare the struct ifreq (interface request)
    # Format '16sH': 16 bytes for name, 2 bytes (Short) for flags
    # We strip the name to 15 chars + null terminator
    ifr_name = dev_name.encode('utf-8')[:15]
    ifr_flags = IFF_TUN | IFF_NO_PI
    
    # Pack the data into binary format expected by C ioctl
    ifr = struct.pack('16sH', ifr_name, ifr_flags)
    
    # Send the ioctl command to the kernel
    fcntl.ioctl(tun_fd, TUNSETIFF, ifr)
    
    print(f"Interface {dev_name} created successfully.")
    return tun_fd
