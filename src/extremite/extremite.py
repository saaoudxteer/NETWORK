import socket
import os
import select

# Parameters
PORT = 123
BUF_SIZE = 2048 

def tunnel_loop(tun_fd, sock):
    """
    Main loop for bidirectional data transfer (Part 3.3):
    - Reads from TUN -> Sends to Socket (Outgoing traffic)
    - Reads from Socket -> Writes to TUN (Incoming traffic)
    """
    print(f"Tunnel bidirectional active. (Press Ctrl+C to stop)")
    
    # We monitor two file descriptors: the TUN interface and the Socket
    inputs = [tun_fd, sock]

    try:
        while True:
            # select blocks until data is available on either interface
            readable, _, _ = select.select(inputs, [], [])

            for source in readable:
                if source is tun_fd:
                    # Data from Kernel (TUN) -> Send to Network
                    packet = os.read(tun_fd, BUF_SIZE)
                    if packet:
                        sock.sendall(packet)

                elif source is sock:
                    # Data from Network (Socket) -> Inject into Kernel
                    data = sock.recv(BUF_SIZE)
                    if not data:
                        print("Connection closed by remote.")
                        return 
                    os.write(tun_fd, data)

    except KeyboardInterrupt:
        print("Stopping tunnel...")

def ext_out(tun_fd):
    """ Server Side: Accepts connection then starts tunnel """
    server_sock = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    
    try:
        server_sock.bind(('::', PORT))
        server_sock.listen(1)
        print(f"Server listening on port {PORT}...")
        
        client_sock, addr = server_sock.accept()
        print(f"Connection accepted from {addr}")
        
        # Start the bidirectional loop
        tunnel_loop(tun_fd, client_sock)
        
    finally:
        server_sock.close()

def ext_in(tun_fd, remote_ip):
    """ Client Side: Connects then starts tunnel """
    client_sock = socket.socket(socket.AF_INET6, socket.SOCK_STREAM)
    
    try:
        print(f"Connecting to {remote_ip} on port {PORT}...")
        client_sock.connect((remote_ip, PORT))
        print("Connected!")
        
        # Start the bidirectional loop
        tunnel_loop(tun_fd, client_sock)
        
    except ConnectionRefusedError:
        print("Error: Connection refused. Is the server running?")
    finally:
        client_sock.close()

def tunnel_loop(tun_fd, sock):
    # On ajoute des mouchards pour voir le trafic passer
    print(f"--- Tunnel actif ---")
    
    inputs = [tun_fd, sock]

    try:
        while True:
            readable, _, _ = select.select(inputs, [], [])

            for source in readable:
                if source is tun_fd:
                    # Sens : TUN -> RÉSEAU
                    packet = os.read(tun_fd, BUF_SIZE)
                    if packet:
                        # Si ce message ne s'affiche pas, le problème est avant (dans le système)
                        print(f"--> TUN: Lu {len(packet)} octets. Envoi...")
                        sock.sendall(packet)

                elif source is sock:
                    # Sens : RÉSEAU -> TUN
                    data = sock.recv(BUF_SIZE)
                    if not data:
                        print("Connexion fermée par le distant.")
                        return 
                    print(f"<-- NET: Reçu {len(data)} octets. Ecriture...")
                    os.write(tun_fd, data)

    except KeyboardInterrupt:
        print("Arrêt du tunnel.")
    except Exception as e:
        # Ceci affichera l'erreur réelle si le script plante
        print(f"ERREUR CRITIQUE: {e}")