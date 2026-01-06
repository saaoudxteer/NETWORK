#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

LAN1_IF="${LAN1_IF:-eth1}"   # 172.16.2.131/28
LAN3_IF="${LAN3_IF:-eth2}"   # 172.16.2.151/28

link_up "$LAN1_IF"
link_up "$LAN3_IF"
flush_v4 "$LAN1_IF"
flush_v4 "$LAN3_IF"
add_v4 "$LAN1_IF" "172.16.2.131/28"
add_v4 "$LAN3_IF" "172.16.2.151/28"

# VM1 doit router IPv4 pour certains tests
enable_ipv4_forward

show_state
