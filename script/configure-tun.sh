#!/usr/bin/env bash
set -euo pipefail

IFACE="${1:-tun0}"
ADDR="${2:-172.16.2.1/28}"
DST="${3:-172.16.2.10/32}"

ip link set "$IFACE" up
ip -4 addr flush dev "$IFACE"
ip addr add "$ADDR" dev "$IFACE"
ip route replace "$DST" dev "$IFACE"

ip -brief addr show dev "$IFACE"
ip route get "${DST%/*}" || true
