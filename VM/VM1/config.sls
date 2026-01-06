# ============================
# VM1 CONFIG (Version Robuste)
# ============================

NetworkManager:
  service:
    - dead
    - enable: False

ip route del default:
  cmd.run

# Interface eth1 (IPv4 - LAN1)
eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: static
    - ipaddr: 172.16.2.131
    - netmask: 28
    # Ajout de la route LAN2 directement ici via commande systeme
    - up_cmds:
      - ip route add 172.16.2.160/28 via 172.16.2.132 dev eth1 || true

# Interface eth2 (IPv6 - LAN3-6)
eth2:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - enable_ipv6: true
    - ipv6proto: static
    - ipv6ipaddr: fc00:1234:3::1
    - ipv6netmask: 64
    - ipv6_autoconf: no
    # Ajout de la route IPv6 directement ici
    - up_cmds:
      - ip -6 route add fc00:1234::/32 via fc00:1234:3::16 dev eth2 || trues
