import socket
import os
import sys
from tun import tun_open

def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 123

    tunfd = tun_open("tun0", no_pi=True)

    s = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("::", port))
    s.listen(1)

    print(f"[ext_out] listening on ::: {port}")
    conn, addr = s.accept()
    print(f"[ext_out] client connected: {addr}")

    try:
        while True:
            data = conn.recv(4096)
            if not data:
                print("[ext_out] connection closed")
                break
            os.write(tunfd, data)
    finally:
        conn.close()
        s.close()
        os.close(tunfd)

if __name__ == "__main__":
    main()
