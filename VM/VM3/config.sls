# ============================
# VM3 CONFIG (Version Robuste)
# ============================

NetworkManager:
  service:
    - dead
    - enable: False

ip route del default:
  cmd.run

# Interface eth1 (IPv4 - LAN2)
eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: 172.16.2.163
    - netmask: 28
    # Route vers LAN1
    - up_cmds:
      - ip route add 172.16.2.128/28 via 172.16.2.162 dev eth1 || true

# Interface eth2 (IPv6 - LAN4-6)
eth2:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - enable_ipv6: true
    - ipv6proto: static
    - ipv6ipaddr: fc00:1234:4::3
    - ipv6netmask: 64
    - ipv6_autoconf: no
    # Route vers le monde IPv6
    - up_cmds:
      - ip -6 route add fc00:1234::/32 via fc00:1234:4::36 dev eth2 || true
