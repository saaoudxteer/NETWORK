#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

LAN4_IF="${LAN4_IF:-eth1}"     # 172.16.2.186/28
LAN2_6_IF="${LAN2_6_IF:-eth2}" # fc00:1234:2::36/64

link_up "$LAN4_IF"
flush_v4 "$LAN4_IF"
add_v4 "$LAN4_IF" "172.16.2.186/28"

enable_ipv6
link_up "$LAN2_6_IF"
flush_v6 "$LAN2_6_IF"
add_v6 "$LAN2_6_IF" "fc00:1234:2::36/64"

show_state
