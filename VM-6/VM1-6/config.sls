# ============================
# VM1-6 CONFIG (IDs Uniques)
# ============================

# ID unique : vm16_nm
vm16_disable_network_manager:
  service.dead:
    - name: NetworkManager
    - enable: False

# ID unique : vm16_route
vm16_remove_default_route:
  cmd.run:
    - name: ip route del default
    - unless: ip route show | grep -v default

# ID unique : vm16_fwd
vm16_enable_ipv6_forwarding:
  sysctl.present:
    - name: net.ipv6.conf.all.forwarding
    - value: 1

# Interface eth1 — LAN3-6
eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - enable_ipv4: false
    - ipv6proto: static
    - enable_ipv6: true
    - ipv6_autoconf: no
    - ipv6ipaddr: fc00:1234:3::16
    - ipv6netmask: 64

# Interface eth2 — LAN1-6
eth2:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - enable_ipv4: false
    - ipv6proto: static
    - enable_ipv6: true
    - ipv6_autoconf: no
    - ipv6ipaddr: fc00:1234:1::16
    - ipv6netmask: 64

# Routes VM1-6 (Via commande directe pour éviter les conflits)
vm16_setup_routes:
  cmd.run:
    - name: |
        # Vers LAN2-6 via VM2-6
        ip -6 route add fc00:1234:2::/64 via fc00:1234:1::26 dev eth2 || true
        # Vers LAN4-6 via VM2-6
        ip -6 route add fc00:1234:4::/64 via fc00:1234:1::26 dev eth2 || true
