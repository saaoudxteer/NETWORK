#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

LAN2_IF="${LAN2_IF:-eth1}"   # 172.16.2.163/28
LAN4_IF="${LAN4_IF:-eth2}"   # 172.16.2.183/28

link_up "$LAN2_IF"
link_up "$LAN4_IF"
flush_v4 "$LAN2_IF"
flush_v4 "$LAN4_IF"
add_v4 "$LAN2_IF" "172.16.2.163/28"
add_v4 "$LAN4_IF" "172.16.2.183/28"

show_state
