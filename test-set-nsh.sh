#!/bin/bash

. set-ovs-env.sh

./my-ovs-vsctl add-br br0 -- set bridge br0 datapath-type=dummy fail-mode=secure
./my-ovs-vsctl add-port br0 p1 -- set Interface p1 type=dummy ofport_request=1
./my-ovs-vsctl add-port br0 p2 -- set Interface p2 type=vxlan \
         options:layer3=true,options:exts=gpe options:remote_ip=1.1.1.1 \
         options:dst_port=4790 ofport_request=2
./my-ovs-vsctl add-port br0 p90 -- set Interface p90 type=dummy ofport_request=90
./my-ovs-ofctl -Oopenflow13 add-flows br0 flows.txt
./utilities/ovs-appctl -t /home/yyang13/ovs-nsh-test/var/run/openvswitch/ovs-vswitchd.ctl ofproto/trace ovs-dummy 'in_port(90),eth(src=50:54:00:00:00:05,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=1,tos=0,ttl=128,frag=no),icmp(type=8,code=0)'
