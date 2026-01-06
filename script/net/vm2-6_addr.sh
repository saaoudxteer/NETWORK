#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

LAN1_6_IF="${LAN1_6_IF:-eth1}" # fc00:1234:1::26/64
LAN2_6_IF="${LAN2_6_IF:-eth2}" # fc00:1234:2::26/64

enable_ipv6
link_up "$LAN1_6_IF"
link_up "$LAN2_6_IF"
flush_v6 "$LAN1_6_IF"
flush_v6 "$LAN2_6_IF"
add_v6 "$LAN1_6_IF" "fc00:1234:1::26/64"
add_v6 "$LAN2_6_IF" "fc00:1234:2::26/64"

# VM2-6 route IPv6
enable_ipv6_forward

show_state
