sudo -s
cd /vagrant
mkdir -p script/tun

cat > script/tun/setup_tun0.sh <<'EOF'
#!/bin/bash
set -euxo pipefail

ROLE="${1:-}"
IFACE="tun0"

if [[ "$ROLE" != "vm1-6" && "$ROLE" != "vm3-6" ]]; then
  echo "Usage: $0 vm1-6|vm3-6"
  exit 2
fi

# Stop anything that may keep /dev/net/tun busy
pkill -f tunnel46d.py 2>/dev/null || true
pkill -f ext_in.py 2>/dev/null || true
pkill -f ext_out.py 2>/dev/null || true
pkill -f tcpdump 2>/dev/null || true

# Remove tun0 if exists (clean state)
ip link del "$IFACE" 2>/dev/null || true

# Ensure tun support
modprobe tun 2>/dev/null || true

# Create tun0
ip tuntap add dev "$IFACE" mode tun
ip link set "$IFACE" up
ip addr flush dev "$IFACE"

# Role-specific address + route injection
if [[ "$ROLE" == "vm1-6" ]]; then
  ip addr add 172.16.2.1/24 dev "$IFACE"
  ip route replace 172.16.2.176/28 dev "$IFACE"   # LAN4 -> tunnel
else
  ip addr add 172.16.2.10/24 dev "$IFACE"
  ip route replace 172.16.2.144/28 dev "$IFACE"   # LAN3 -> tunnel
fi

# Enable forwarding + avoid silent drops
sysctl -w net.ipv4.ip_forward=1 >/dev/null
sysctl -w net.ipv4.conf.all.rp_filter=0 >/dev/null
sysctl -w net.ipv4.conf.default.rp_filter=0 >/dev/null

# Let forwarding pass (TP setting)
iptables -P FORWARD ACCEPT 2>/dev/null || true

echo "[OK] $IFACE configured for $ROLE"
ip -br addr show "$IFACE"
ip route | grep "$IFACE" || true
