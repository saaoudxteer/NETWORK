# ============================
# VM3-6 CONFIG (IDs Uniques)
# ============================

# ID unique : vm36_nm
vm36_disable_network_manager:
  service.dead:
    - name: NetworkManager
    - enable: False

# ID unique : vm36_route
vm36_remove_default_route:
  cmd.run:
    - name: ip route del default
    - unless: ip route show | grep -v default

# ID unique : vm36_fwd
vm36_enable_ipv6_forwarding:
  sysctl.present:
    - name: net.ipv6.conf.all.forwarding
    - value: 1

# Interface eth1 — LAN4-6
eth1:
  network.managed:
    - enabled: True
    - type: eth
    - proto: none
    - enable_ipv4: false
    - ipv6proto: static
    - enable_ipv6: true
    - ipv6_autoconf: no
    - ipv6ipaddr: fc00:1234:4::36
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
    - ipv6ipaddr: fc00:1234:2::36
    - ipv6netmask: 64

# Routes VM3-6 (Via commande directe pour éviter les conflits)
vm36_setup_routes:
  cmd.run:
    - name: |
        # Vers LAN1-6 via VM2-6
        ip -6 route add fc00:1234:1::/64 via fc00:1234:2::26 dev eth2 || true
        # Vers LAN3-6 via VM2-6
        ip -6 route add fc00:1234:3::/64 via fc00:1234:2::26 dev eth2 || true
        
# ============================
# CONFIGURATION SERVICE ECHO
# ============================

# 1. Installer le paquet inetutils-inetd
installer_inetd:
  pkg.installed:
    - name: inetutils-inetd

# 2. Configurer le service echo dans inetd
# On utilise cmd.run pour lancer la commande update-inetd comme demandé
configurer_echo:
  cmd.run:
    - name: update-inetd --add "echo stream tcp6 nowait nobody internal"
    - require:
      - pkg: installer_inetd
    # 'unless' empêche de lancer la commande si la ligne existe déjà (évite les doublons)
    - unless: grep "echo stream tcp6" /etc/inetd.conf

# 3. S'assurer que le service tourne
demarrer_inetd:
  service.running:
    - name: inetutils-inetd
    - enable: True
    - watch:
      - cmd: configurer_echo
