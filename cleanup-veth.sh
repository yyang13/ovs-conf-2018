#!/bin/bash

sudo pkill python3
sudo ip netns exec app ip link set dev lo down
sudo ip netns exec app ip link set dev veth-app down
sudo ip netns exec app ifconfig veth-app down
sudo ip link set dev veth-br down
sudo ./my-ovs-vsctl del-port br-int veth-br
sudo ip link del veth-app
sudo ip netns del app
