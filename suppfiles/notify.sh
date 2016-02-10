#!/bin/bash
set -x
#exec > >(tee /tmp/somefile.log) 2>&1
TYPE=$1
NAME=$2
STATE=$3
case $STATE in
    "MASTER")
    conntrackd -c
    conntrackd -f
    conntrackd -R
    sysctl -w net.ipv4.vs.conntrack=1
    iptables -t nat -D PREROUTING -p tcp -d 192.168.252.254/32 -j DNAT --to {{ salt['grains.get']('ip4_interfaces:eth1')[0] }} || true
    iptables -t nat -A PREROUTING -p tcp -d 192.168.252.254/32 -j DNAT --to {{ salt['grains.get']('ip4_interfaces:eth1')[0] }}
    iptables -t nat -D POSTROUTING -m ipvs --vaddr {{ salt['grains.get']('ip4_interfaces:eth1')[0] }} -o eth1 -j SNAT --to {{ salt['grains.get']('ip4_interfaces:eth1')[0] }} || true
    iptables -t nat -A POSTROUTING -m ipvs --vaddr {{ salt['grains.get']('ip4_interfaces:eth1')[0] }} -o eth1 -j SNAT --to {{ salt['grains.get']('ip4_interfaces:eth1')[0] }}
    iptables -t nat -D POSTROUTING -m ipvs --vaddr 192.168.252.254 -o eth0 -j SNAT --to 192.168.252.254 || true
    iptables -t nat -A POSTROUTING -m ipvs --vaddr 192.168.252.254 -o eth0 -j SNAT --to 192.168.252.254
    exit 0
    ;;
    "BACKUP")
    conntrackd -n
    iptables -t nat -F
    exit 0
    ;;
    "FAULT")
    conntrackd -n
    iptables -t nat -F
    exit 0
    ;;
    *)
    exit 1
    ;;
esac
