import fcntl
import os
import struct

# Linux constants
TUNSETIFF = 0x400454ca
IFF_TUN   = 0x0001
IFF_NO_PI = 0x1000

def tun_open(ifname: str = "tun0", no_pi: bool = True) -> int:
    """
    Ouvre /dev/net/tun et attache le fd à l'interface ifname via ioctl(TUNSETIFF).
    Nécessite root.
    """
    fd = os.open("/dev/net/tun", os.O_RDWR)
    flags = IFF_TUN | (IFF_NO_PI if no_pi else 0)

    ifr = struct.pack("16sH", ifname.encode("utf-8"), flags)
    fcntl.ioctl(fd, TUNSETIFF, ifr)

    return fd
