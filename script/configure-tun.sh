#!/usr/bin/env bash

ip tuntap add dev tun0 mode tun
ip addr add 172.16.2.1/24 dev tun0
ip link set tun0 up
