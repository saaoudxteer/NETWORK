#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

LAN3_IF="${LAN3_IF:-eth1}"     # 172.16.2.156/28
LAN1_6_IF="${LAN1_6_IF:-eth2}" # fc00:1234:1::16/64

link_up "$LAN3_IF"
flush_v4 "$LAN3_IF"
add_v4 "$LAN3_IF" "172.16.2.156/28"

enable_ipv6
link_up "$LAN1_6_IF"
flush_v6 "$LAN1_6_IF"
add_v6 "$LAN1_6_IF" "fc00:1234:1::16/64"

show_state
