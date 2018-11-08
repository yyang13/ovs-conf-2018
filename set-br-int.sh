#!/bin/bash

source $(dirname $0)/set-ovs-env.sh

VSCTL="${OVS_DIR}/utilities/ovs-vsctl --db=unix:$DB_SOCK"

echo "Creating OvS bridge and adding vxlan and vxlan-gpe ports into it..."
${VSCTL} del-br br-int
${VSCTL} add-br br-int -- set bridge br-int datapath_type=netdev protocols=OpenFlow10,OpenFlow12,OpenFlow13

${VSCTL} add-port br-int dpdk0 -- set Interface dpdk0 type=dpdk options:dpdk-devargs=0000:08:00.1

${VSCTL} add-port br-int vxlan1 -- set interface vxlan1 type=vxlan options:remote_ip=flow options:key=flow

${VSCTL} add-port br-int vxlan_gpe1 -- set interface vxlan_gpe1 type=vxlan options:remote_ip=flow options:key=flow options:dst_port=4790 options:exts=gpe options:packet_type=ptap

#${VSCTL} add-port br-int dpdkvhostuser1 -- set Interface dpdkvhostuser1 type=dpdkvhostuser
${VSCTL} add-port br-int dpdkvhostuser1 -- set Interface dpdkvhostuser1 type=dpdk options:dpdk-devargs=net_vhost0,iface=/var/run/openvswitch/dpdkvhostuser1,queues=1
#${VSCTL} add-port br-int dpdkvhostuser2 -- set Interface dpdkvhostuser2 type=dpdkvhostuser
${VSCTL} add-port br-int dpdkvhostuser2 -- set Interface dpdkvhostuser2 type=dpdk options:dpdk-devargs=net_vhost1,iface=/var/run/openvswitch/dpdkvhostuser2,queues=1

ifconfig br-int 192.168.60.71 netmask 255.255.255.0 up

./setup-veth.sh
