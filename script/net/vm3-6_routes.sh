#!/usr/bin/env bash
set -euo pipefail
source /vagrant/script/net/lib.sh
need_root

# VM2-6 côté LAN2-6 = fc00:1234:2::26
route_v6_replace_via "fc00:1234:1::/64" "fc00:1234:2::26"
show_state
