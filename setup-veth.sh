#!/bin/bash

sudo ip netns add app
sudo ip link add veth-app type veth peer name veth-br
sudo ./my-ovs-vsctl add-port br-int veth-br
sudo ip link set dev veth-br up
sudo ip link set veth-app netns app
host="gbpsfc2"
if [ "${host}"  == "gbpsfc2" ] ; then
    sudo ip netns exec app ifconfig veth-app 10.1.1.10/24 up
    sudo ip netns exec app ip link set dev veth-app  addr 00:00:11:11:11:11
    #sudo ip netns exec app arp -s 192.168.2.2 00:00:22:22:22:22 -i veth-app
    sudo ip netns exec app ip link set dev veth-app up
    sudo ip netns exec app ip link set dev lo up
    sudo ip netns exec app ifconfig veth-app mtu 1400
    sudo ip netns exec app ethtool -K veth-app tx off
fi

if [ "${host}"  == "gbpsfc5" ] ; then
    sudo ip netns exec app ifconfig veth-app 192.168.2.2/24 up
    sudo ip netns exec app ip link set dev veth-app  addr 00:00:22:22:22:22
    sudo ip netns exec app arp -s 192.168.2.1 00:00:11:11:11:11 -i veth-app
    sudo ip netns exec app ip link set dev veth-app up
    sudo ip netns exec app ip link set dev lo up
    sudo ip netns exec app ifconfig veth-app mtu 1400
    sudo ip netns exec app ethtool -K veth-app tx off
    sudo ip netns exec app python3 -m http.server 80
fi
sudo ./my-ovs-vsctl show
