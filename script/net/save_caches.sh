#!/usr/bin/env bash
sudo sysctl -w net.ipv6.neigh.default.gc_stale_time=36000
sudo sysctl -w net.ipv4.neigh.default.gc_stale_time=36000





