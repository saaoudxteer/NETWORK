# ============================
# VM2-6 CONFIG (CORRIGÉ)
# ============================

# On utilise un ID unique et propre
disable_network_manager_vm26:
  service.dead:
    - name: NetworkManager
    - enable: False

# Suppression route IPv4
remove_default_route_vm26:
  cmd.run:
    - name: ip route del default
    - unless: ip route show | grep -v default  # Ne lance la commande que si une route existe

# Activation du forwarding IPv6
enable_ipv6_forwarding_vm26:
  sysctl.present:
    - name: net.ipv6.conf.all.forwarding
    - value: 1

# Interface eth1 — LAN1-6
eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - enable_ipv4: false
    - ipv6proto: static
    - enable_ipv6: true
    - ipv6_autoconf: no
    - ipv6ipaddr: fc00:1234:1::26
    - ipv6netmask: 64

# Interface eth2 — LAN2-6
eth2:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - enable_ipv4: false
    - ipv6proto: static
    - enable_ipv6: true
    - ipv6_autoconf: no
    - ipv6ipaddr: fc00:1234:2::26
    - ipv6netmask: 64

# Routes VM2-6 (Version "Up Commands" plus robuste)
# On attache les routes aux interfaces pour éviter les conflits
setup_routes_vm26:
  cmd.run:
    - name: |
        ip -6 route add fc00:1234:3::/64 via fc00:1234:1::16 dev eth1 || true
        ip -6 route add fc00:1234:4::/64 via fc00:1234:2::36 dev eth2 || true
