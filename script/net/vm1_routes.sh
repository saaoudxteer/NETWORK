#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

# VM2 sur LAN1 = 172.16.2.132
route_v4_replace "172.16.2.160/28" "172.16.2.132"  # LAN2
route_v4_replace "172.16.2.176/28" "172.16.2.132"  # LAN4
enable_ipv4_forward
show_state
