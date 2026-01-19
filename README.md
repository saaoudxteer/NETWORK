Here is the **final, professional English version**, ready to copy and paste directly into your `README.md`.

```markdown
# 🌐 IPv4-over-TCP/IPv6 Tunneling

![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python&logoColor=white)
![Linux](https://img.shields.io/badge/Platform-Linux-lightgrey?logo=linux)
![Network](https://img.shields.io/badge/Network-TCP%2FIP-success)
![Vagrant](https://img.shields.io/badge/Infrastructure-Vagrant-orange)

## 📖 Overview

This project implements a custom **network tunneling protocol** designed to encapsulate IPv4 traffic within a TCP/IPv6 stream. By directly interacting with Linux **TUN virtual interfaces**, the program intercepts Network Layer (L3) packets, encapsulates them, and transports them across a dual-stack infrastructure.

This solution simulates a real-world network engineering scenario: interconnecting two isolated legacy IPv4 islands (due to a direct link failure or migration) through an exclusively IPv6 backbone.

## 🚀 Key Features

- **Virtual TUN Interface:** Low-level packet manipulation via the `/dev/net/tun` file descriptor.
- **Hybrid Encapsulation:** Transport of raw IPv4 packets within a TCP/IPv6 data stream.
- **Infrastructure as Code:** Automated deployment of a complex network topology (6 VMs, 2 routers) using **Vagrant** and **SaltStack**.
- **Routing Management:** Automation scripts for configuring routing tables and IP addressing.
- **Performance Analysis:** Support for bandwidth and latency benchmarking via `iperf3`.

## 🏗️ Architecture and Topology

The simulation environment is divided into two segments: the Legacy IPv4 Network and the IPv6 Backbone.

| Node | Role | IP Configuration |
|------|------|------------------|
| **VM1** | Client (Source) | `172.16.2.151/28` |
| **VM3** | Server (Target) | `172.16.2.183/28` |
| **VM1-6** | Tunnel Endpoint A | IPv4: `172.16.2.156` / IPv6: `fc00:1234:1::16` |
| **VM3-6** | Tunnel Endpoint B | IPv4: `172.16.2.186` / IPv6: `fc00:1234:2::36` |

**Data Flow:**
`Client (VM1)` → `Gateway (VM1-6 TUN)` → `[Encapsulation]` → `TCP/IPv6 Transport` → `[Decapsulation]` → `Target (VM3)`

## 🛠️ Project Structure

The codebase separates application logic (Python) from infrastructure configuration (Vagrant/Shell).

```text
.
├── docs/                # Documentation, diagrams, and Wireshark captures
├── script/
│   └── net/             # Network configuration scripts (IP, Routing)
│       ├── vm1_routes.sh
│       ├── vm1-6_routes.sh
│       └── ...
├── src/
│   ├── extremite/       # Tunnel Core (Python Logic)
│   │   ├── tunnel46d.py # Main encapsulation/decapsulation daemon
│   │   ├── iftun.py     # TUN interface management library
│   │   └── extremite.py # Inbound/Outbound connection handling
│   └── iftun/           # Unit testing tools for TUN interfaces
├── VM/                  # Vagrant Environment: Legacy IPv4 Network (VM1, VM2, VM3)
├── VM-6/                # Vagrant Environment: IPv6 Backbone (VM1-6, VM2-6, VM3-6)
└── Makefile             # Global Automation (Startup, Cleanup, Testing)

```

## 💻 Installation and Deployment

### Prerequisites

* **Host OS:** Linux, macOS, or Windows.
* **Virtualization:** VirtualBox & Vagrant.
* **Tools:** Python 3, GNU Make.

### Quick Start

1. **Clone the repository:**
```bash
git clone [https://github.com/yourusername/ipv4-over-ipv6-tunnel.git](https://github.com/yourusername/ipv4-over-ipv6-tunnel.git)
cd ipv4-over-ipv6-tunnel

```


2. **Launch the simulation environment:**
This command starts all VMs (IPv4 and IPv6) via Vagrant.
```bash
make up

```


3. **Tunnel Configuration:**
Route deployment and `tun0` interface initialization are handled by the scripts located in `src/extremite/` and `script/net/`.

## 🧪 Testing and Validation

### 1. Layer 3 Connectivity (ICMP)

Verifying that packets correctly traverse the tunnel.

```bash
# From VM1 terminal
ping 172.16.2.183

```

### 2. Layer 4 Application Transport (TCP)

Transmitting raw data through the tunnel managed by `tunnel46d.py`.

```bash
# Server (VM3)
nc -l -p 1234

# Client (VM1)
echo "HELLO_TUNNEL" | nc 172.16.2.183 1234

```

### 3. Benchmarking

Load testing performed with `iperf3` to validate tunnel robustness under various buffer sizes (MTU/Buffer).
