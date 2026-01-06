#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

# VM1 sur LAN3 = 172.16.2.151
route_v4_replace "172.16.2.176/28" "172.16.2.151"
show_state
