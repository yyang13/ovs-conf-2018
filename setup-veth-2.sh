#!/bin/bash

sudo ip netns add app2
sudo ip link add veth-app2 type veth peer name veth-br2
sudo ./my-ovs-vsctl add-port br-int veth-br2
sudo ip link set dev veth-br2 up
sudo ip link set veth-app2 netns app2
host="gbpsfc5"
if [ "${host}"  == "gbpsfc2" ] ; then
    sudo ip netns exec app2 ifconfig veth-app2 192.168.2.1/24 up
    sudo ip netns exec app2 ip link set dev veth-app2  addr 00:00:11:11:11:11
    sudo ip netns exec app2 arp -s 192.168.2.2 00:00:22:22:22:22 -i veth-app2
    sudo ip netns exec app2 ip link set dev veth-app2 up
    sudo ip netns exec app2 ip link set dev lo up
    sudo ip netns exec app2 ifconfig veth-app2 mtu 1400
    sudo ip netns exec app2 ethtool -K veth-app2 tx off
fi

if [ "${host}"  == "gbpsfc5" ] ; then
    sudo ip netns exec app2 ifconfig veth-app2 192.168.2.2/24 up
    sudo ip netns exec app2 ip link set dev veth-app2  addr 00:00:22:22:22:22
    sudo ip netns exec app2 arp -s 192.168.2.1 00:00:11:11:11:11 -i veth-app2
    sudo ip netns exec app2 ip link set dev veth-app2 up
    sudo ip netns exec app2 ip link set dev lo up
    sudo ip netns exec app2 ifconfig veth-app2 mtu 1400
    sudo ip netns exec app2 ethtool -K veth-app2 tx off
    sudo ip netns exec app2 python3 -m http.server 80
fi
sudo ./my-ovs-vsctl show
