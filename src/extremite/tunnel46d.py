import os, sys, socket, selectors, struct, fcntl

TUNSETIFF = 0x400454ca
IFF_TUN   = 0x0001
IFF_NO_PI = 0x1000

def tun_open(ifname: str = "tun0") -> int:
    fd = os.open("/dev/net/tun", os.O_RDWR)
    ifr = struct.pack("16sH", ifname.encode(), IFF_TUN | IFF_NO_PI)
    fcntl.ioctl(fd, TUNSETIFF, ifr)
    return fd

def pack_frame(pkt: bytes) -> bytes:
    return struct.pack("!H", len(pkt)) + pkt

def unpack_frames(buf: bytearray):
    out = []
    while True:
        if len(buf) < 2:
            break
        (n,) = struct.unpack("!H", buf[:2])
        if len(buf) < 2 + n:
            break
        out.append(bytes(buf[2:2+n]))
        del buf[:2+n]
    return out

def usage():
    print("Usage:")
    print("  tunnel46d.py listen <port>")
    print("  tunnel46d.py connect <dst_ipv6> <port>")
    sys.exit(2)

def main():
    if os.geteuid() != 0:
        print("Run as root.")
        sys.exit(1)

    if len(sys.argv) < 3:
        usage()

    mode = sys.argv[1]
    sel = selectors.DefaultSelector()

    tunfd = tun_open("tun0")
    os.set_blocking(tunfd, False)

    sock = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
    sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    if mode == "listen":
        port = int(sys.argv[2])
        sock.bind(("::", port))
        sock.listen(1)
        print(f"[tunnel46d] listening on ::: {port}")
        conn, addr = sock.accept()
        print(f"[tunnel46d] accepted {addr}")
        sock.close()
        s = conn
    elif mode == "connect":
        if len(sys.argv) < 4:
            usage()
        dst = sys.argv[2]
        port = int(sys.argv[3])
        print(f"[tunnel46d] connecting to [{dst}]:{port}")
        sock.connect((dst, port))
        s = sock
        print("[tunnel46d] connected")
    else:
        usage()

    s.setblocking(False)
    rxbuf = bytearray()

    sel.register(tunfd, selectors.EVENT_READ, data="tun")
    sel.register(s, selectors.EVENT_READ, data="sock")

    try:
        while True:
            for key, _ in sel.select():
                if key.data == "tun":
                    pkt = os.read(tunfd, 4096)
                    if pkt:
                        s.sendall(pack_frame(pkt))
                else:
                    data = s.recv(4096)
                    if not data:
                        print("[tunnel46d] peer closed")
                        return
                    rxbuf.extend(data)
                    for pkt in unpack_frames(rxbuf):
                        os.write(tunfd, pkt)
    finally:
        try: sel.unregister(tunfd)
        except: pass
        try: sel.unregister(s)
        except: pass
        try: s.close()
        except: pass
        try: os.close(tunfd)
        except: pass

if __name__ == "__main__":
    main()
