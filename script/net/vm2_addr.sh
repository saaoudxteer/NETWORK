#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

LAN1_IF="${LAN1_IF:-eth1}"   # 172.16.2.132/28
LAN2_IF="${LAN2_IF:-eth2}"   # 172.16.2.162/28

link_up "$LAN1_IF"
link_up "$LAN2_IF"
flush_v4 "$LAN1_IF"
flush_v4 "$LAN2_IF"
add_v4 "$LAN1_IF" "172.16.2.132/28"
add_v4 "$LAN2_IF" "172.16.2.162/28"

# VM2 doit router IPv4 pour les tests de connectivité avant tunnel
enable_ipv4_forward

show_state

