# ============================
# VM2 CONFIG
# ============================

NetworkManager:
  service:
    - dead
    - enable: False

ip route del default:
  cmd.run

# Activation du routage IPv4
net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

# Interface eth1 (LAN1)
eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: 172.16.2.132
    - netmask: 28

# Interface eth2 (LAN2)
eth2:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: 172.16.2.162
    - netmask: 28
