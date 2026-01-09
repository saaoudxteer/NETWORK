#!/usr/bin/env bash
set -euo pipefail

IFACES=("eth1" "eth2")

for dev in "${IFACES[@]}"; do
  if ! ip link show "$dev" >/dev/null 2>&1; then
    echo "[!] Interface inexistante: $dev (skip)"
    continue
  fi

  echo "[*] Cleaning $dev"

  # Supprimer toutes les adresses IPv4 + IPv6
  ip addr flush dev "$dev"

  # Supprimer les routes associées (propre pour une démo)
  ip route flush dev "$dev" || true
  ip -6 route flush dev "$dev" || true

  # Reset physique de l’interface
  ip link set dev "$dev" down
  ip link set dev "$dev" up
done

echo "[*] État final :"
ip -br addr show eth1 eth2
