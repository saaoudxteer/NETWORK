#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

route_v4_replace "172.16.2.144/28" "172.16.2.131"  # LAN3 via VM1 (LAN1)
route_v4_replace "172.16.2.176/28" "172.16.2.163"  # LAN4 via VM3 (LAN2)
enable_ipv4_forward
show_state
