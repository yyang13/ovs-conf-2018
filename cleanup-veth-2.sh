#!/bin/bash

sudo pkill python3
sudo ip netns exec app2 ip link set dev lo down
sudo ip netns exec app2 ip link set dev veth-app2 down
sudo ip netns exec app2 ifconfig veth-app2 down
sudo ip link set dev veth-br2 down
sudo ./my-ovs-vsctl del-port br-int veth-br2
sudo ip link del veth-app2
sudo ip netns del app2
