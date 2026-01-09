import socket
import os
import sys
from tun import tun_open

def main():
    if len(sys.argv) < 2:
        print("Usage: ext_in.py <dst_ipv6> [port]")
        raise SystemExit(2)

    dst = sys.argv[1]
    port = int(sys.argv[2]) if len(sys.argv) > 2 else 123

    tunfd = tun_open("tun0", no_pi=True)

    s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
    print(f"[ext_in] connecting to [{dst}]:{port}")
    s.connect((dst, port))
    print("[ext_in] connected")

    try:
        while True:
            data = os.read(tunfd, 4096)
            if not data:
                continue
            s.sendall(data)
    finally:
        s.close()
        os.close(tunfd)

if __name__ == "__main__":
    main()
