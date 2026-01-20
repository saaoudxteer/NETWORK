# IPv4 over TCP/IPv6 Tunnel

This repository implements an IPv4 tunnel encapsulated in a TCP/IPv6 stream using a Linux TUN interface. The scenario simulates a failure of an intermediate IPv4 router (VM2): two IPv4 islands (LAN3 and LAN4) must keep communicating through an IPv6 backbone (VM1-6/VM2-6/VM3-6).

## Reference documents
The provided documents live in `docs/`:
- Project instructions: [pageperso.lis-lab.fr_emmanuel.godard_enseignement_tps-reseaux_projet_.pdf](docs/pageperso.lis-lab.fr_emmanuel.godard_enseignement_tps-reseaux_projet_.pdf)
- Project report: [Reseau_Projet (1).pdf](docs/R%C3%A9seau_Projet%20(1).pdf)

![Problem statement](docs/images/our_problem.png)

## Architecture and topology

Initial topology (VM2 up):
![Initial topology](docs/images/intial_toplogie.png)

Topology with the TCP/IPv6 tunnel between VM1-6 and VM3-6:
![Tunnel topology](docs/images/topology_diagram.png)

End-to-end path of an IPv4 packet through the tunnel:
![IPv4 to IPv6 path](docs/images/complete_path_ipv4_to_ipv6.png)

### Nodes and addressing (excerpt)
| Node | Role | IPv4 | IPv6 |
| --- | --- | --- | --- |
| VM1 | IPv4 client (LAN3) | 172.16.2.151/28 | - |
| VM3 | IPv4 server (LAN4) | 172.16.2.183/28 | - |
| VM1-6 | Tunnel endpoint A | 172.16.2.156/28 | fc00:1234:1::16/64 |
| VM3-6 | Tunnel endpoint B | 172.16.2.186/28 | fc00:1234:2::36/64 |

Networks in use:
- IPv4 LAN3: 172.16.2.144/28
- IPv4 LAN4: 172.16.2.176/28
- IPv6 LAN1-6: fc00:1234:1::/64
- IPv6 LAN2-6: fc00:1234:2::/64

## Repository layout
- `docs/`: instructions, report, and images.
- `script/net/`: per-VM addressing and routing scripts.
- `src/iftun/`: TUN creation (part 2) and `test_iftun.py`.
- `src/extremite/`: TCP/IPv6 tunnel (`tunnel46d.py`) and intermediate steps (`ext_in.py`, `ext_out.py`, `test_main.py`).
- `VM/` and `VM-6/`: Vagrant environments (IPv4 and IPv6).

## Prerequisites
- Linux host with `/dev/net/tun` and root access.
- Vagrant + VirtualBox.
- Python 3.
- Validation tools: `ip`, `ping`, `nc`, `iperf3`.

## Quick start

### Option A: use the Makefile (recommended)
The root `Makefile` automates Vagrant bringup, network config, tunnel startup, and tests. Typical flow:
```bash
make up
make net
make vm2-down
make tunnel-start
make tun-config
make test-l3
make test-l4
make test-iperf
```

### Option B: manual runbook

1) Start the VMs:
```bash
./VM/start_all_vms.sh
./VM-6/start_all_vms.sh
```

2) Configure addressing and routes (inside each VM):
```bash
# VM1
sudo /vagrant/script/net/vm1_addr.sh
sudo /vagrant/script/net/vm1_routes.sh

# VM2
sudo /vagrant/script/net/vm2_addr.sh
sudo /vagrant/script/net/vm2_routes.sh

# VM3
sudo /vagrant/script/net/vm3_addr.sh
sudo /vagrant/script/net/vm3_routes.sh

# VM1-6
sudo /vagrant/script/net/vm1-6_addr.sh
sudo /vagrant/script/net/vm1-6_routes.sh
sudo /vagrant/script/net/vm1-6_routes_v4.sh

# VM2-6
sudo /vagrant/script/net/vm2-6_addr.sh

# VM3-6
sudo /vagrant/script/net/vm3-6_addr.sh
sudo /vagrant/script/net/vm3-6_routes.sh
```

Tip: `script/net/clean_eth.sh` resets interfaces if needed.

3) Simulate the VM2 failure:
```bash
cd VM/VM2 && vagrant halt
```

4) Start the TCP/IPv6 tunnel (tun0 is created by the process):
```bash
# VM3-6 (server)
sudo python3 /vagrant/src/extremite/tunnel46d.py listen 123

# VM1-6 (client)
sudo python3 /vagrant/src/extremite/tunnel46d.py connect fc00:1234:2::36 123
```

5) Configure tun0 and routes (example):
```bash
# VM1-6: inject LAN4 into tun0
sudo ip addr add 172.16.2.1/24 dev tun0
sudo ip link set tun0 up
sudo ip route replace 172.16.2.176/28 dev tun0
sudo sysctl -w net.ipv4.ip_forward=1

# VM3-6: inject LAN3 into tun0
sudo ip addr add 172.16.2.10/24 dev tun0
sudo ip link set tun0 up
sudo ip route replace 172.16.2.144/28 dev tun0
sudo sysctl -w net.ipv4.ip_forward=1

# VM1: reach LAN4 via VM1-6 (VM2 down)
sudo ip route replace 172.16.2.176/28 via 172.16.2.156

# VM3: reach LAN3 via VM3-6
sudo ip route replace 172.16.2.144/28 via 172.16.2.186
```

## Functional validation

### Layer 3 (ICMP)
```bash
# From VM1
ping 172.16.2.183
```

### Layer 4 (TCP)
```bash
# VM3
nc -l -p 12345

# VM1
echo "HELLO_TUNNEL" | nc 172.16.2.183 12345
```

### Bandwidth (iperf3)
```bash
# VM3
iperf3 -s

# VM1
iperf3 -c 172.16.2.183 -n 1 -l 1M
```

## Implementation notes
- `tunnel46d.py` creates `tun0` with `IFF_NO_PI` and frames packets with a 2-byte length header to preserve boundaries over TCP.
- `ext_in.py` and `ext_out.py` are intermediate steps for parts 3.1 and 3.2 (incoming/outgoing redirection).
- `src/iftun/test_iftun.py` demonstrates raw packet reads on `tun0` for part 2.
