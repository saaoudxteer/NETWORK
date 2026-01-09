import sys
import os
from iftun import tun_alloc
import extremite

def main():
    # Check arguments
    if len(sys.argv) < 2:
        print("Usage:")
        print("  Server: sudo python3 main.py server")
        print("  Client: sudo python3 main.py client <remote_ipv6_address>")
        sys.exit(1)

    mode = sys.argv[1]
    
    # 1. Create Interface
    tun_fd = tun_alloc("tun0")
    
    print("------------------------------------------------")
    print("Interface created. RUN ./configure-tun.sh NOW!")
    print("Press ENTER once configured...")
    print("------------------------------------------------")
    sys.stdin.readline()

    # 2. Run Mode
    if mode == "server":
        extremite.ext_out(tun_fd)
        
    elif mode == "client":
        if len(sys.argv) < 3:
            print("Error: Client mode needs the Server IPv6 address.")
            sys.exit(1)
        remote_ip = sys.argv[2]
        extremite.ext_in(tun_fd, remote_ip)
        
    else:
        print(f"Unknown mode: {mode}")

if __name__ == "__main__":
    main()
