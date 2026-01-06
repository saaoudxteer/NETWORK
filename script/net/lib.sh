#!/usr/bin/env bash
set -euo pipefail

need_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Run as root (sudo)." >&2
    exit 1
  fi
}

link_up() {
  local ifc="$1"
  ip link set "$ifc" up
}

flush_v4() {
  local ifc="$1"
  ip -4 addr flush dev "$ifc" || true
}

flush_v6() {
  local ifc="$1"
  ip -6 addr flush dev "$ifc" || true
}

add_v4() {
  local ifc="$1" cidr="$2"
  ip addr add "$cidr" dev "$ifc"
}

add_v6() {
  local ifc="$1" cidr="$2"
  ip -6 addr add "$cidr" dev "$ifc"
}

enable_ipv4_forward() {
  echo 1 > /proc/sys/net/ipv4/ip_forward
}

enable_ipv6() {
  # Réactive IPv6 si désactivé dans la VM
  echo 0 > /proc/sys/net/ipv6/conf/all/disable_ipv6 || true
  echo 0 > /proc/sys/net/ipv6/conf/default/disable_ipv6 || true
}

enable_ipv6_forward() {
  echo 1 > /proc/sys/net/ipv6/conf/all/forwarding
}

route_v4_replace() {
  local prefix="$1" via="$2"
  ip route replace "$prefix" via "$via"
}

route_v6_replace_via() {
  local prefix="$1" via="$2"
  ip -6 route replace "$prefix" via "$via"
}

show_state() {
  echo "==== IPv4 addrs ===="
  ip -4 -brief addr
  echo "==== IPv6 addrs ===="
  ip -6 -brief addr
  echo "==== IPv4 routes ===="
  ip route
  echo "==== IPv6 routes ===="
  ip -6 route
}
