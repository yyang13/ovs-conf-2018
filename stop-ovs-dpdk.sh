#!/bin/bash

source $(dirname $0)/set-ovs-env.sh

VSCTL="${OVS_DIR}/utilities/ovs-vsctl --db=unix:$DB_SOCK"

echo "Deleting vxlan and vxlan-gpe ports..."
ifconfig br-int down
./cleanup-veth.sh
${VSCTL} del-port br-int vxlan1
${VSCTL} del-port br-int vxlan_gpe1
${VSCTL} del-port br-int dpdk0
${VSCTL} del-port br-int dpdkvhostuser1
${VSCTL} del-port br-int dpdkvhostuser2

${VSCTL} del-br br-int

echo "stop ovs"
dbpid=$(cat $DB_PIDFILE)
if [ "$dbpid" != "" ] ; then
    sudo kill -9 $dbpid
fi
vsdpid=$(cat $VSD_PIDFILE)
if [ "$vsdpid" != "" ] ; then
    sudo kill -9 $vsdpid
fi

rm -f $OVS_CONF_DB
rm -f $DB_CTLSOCK
rm -f $VSD_CTLSOCK
rm -f $DB_SOCK
rm -f $DB_PIDFILE
rm -f $VSD_PIDFILE

modprobe -r vxlan
sudo modprobe -r vport-vxlan
sudo modprobe -r openvswitch
$DPDK_DIR/usertools/dpdk-devbind.py --bind=e1000 0000:00:08.0
ifup eth1
rm -f /var/run/openvswitch/dpdkvhostuser1
rm -f /var/run/openvswitch/dpdkvhostuser2
umount /dev/hugepages
