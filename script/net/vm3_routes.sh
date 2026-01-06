#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

route_v4_replace "172.16.2.144/28" "172.16.2.162"  # LAN3 via VM2 (LAN2)
show_state
