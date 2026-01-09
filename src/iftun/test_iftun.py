import os
import sys
from iftun import tun_alloc

def main():
    # 1. Create the interface
    tun_fd = tun_alloc("tun0")
    
    print(f"TUN interface created (fd={tun_fd}).")
    print("Run './configure-tun.sh' in another terminal now.")
    print("Press ENTER once configured to start reading packets...")
    sys.stdin.readline()
    
    # 2. Continuous Read Loop (The 'perpétuelle' copy)
    print("Reading packets from tun0... (Press Ctrl+C to stop)")
    
    try:
        while True:
            # Read from the file descriptor
            # MTU is usually 1500, so 2048 is a safe buffer size
            packet = os.read(tun_fd, 2048)
            
            # For visualization, we print the raw bytes in Hex
            # This mimics the 'hexdump' requirement in the subject
            print(f"Read {len(packet)} bytes: {packet.hex()}", flush=True)
            
    except KeyboardInterrupt:
        print("\nStopping...")
        os.close(tun_fd)

if __name__ == "__main__":
    main()
