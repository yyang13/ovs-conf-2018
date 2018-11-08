#!/bin/bash

source $(dirname $0)/set-ovs-env.sh
rm -f $OVS_LOG
mkdir -p ${OVS_DIR}/etc/openvswitch
mkdir -p ${OVS_DIR}/var/run/openvswitch

#rmmod vxlan, vport-vxlan and openvswitch
/etc/init.d/openvswitch-switch stop
rmmod vxlan
rmmod vport-vxlan
rmmod openvswitch

#insmod vxlan, vport-vxlan and openvswitch
modprobe libcrc32c
modprobe nf_defrag_ipv6
modprobe nf_nat_ipv6
modprobe gre
insmod $OVS_DIR/datapath/linux/openvswitch.ko
insmod $OVS_DIR/datapath/linux/vport-vxlan.ko

echo "start ovs"
rm -f $OVS_CONF_DB
$OVS_DIR/ovsdb/ovsdb-tool create $OVS_CONF_DB $OVS_DIR/vswitchd/vswitch.ovsschema
$OVS_DIR/ovsdb/ovsdb-server --unixctl=$DB_CTLSOCK --remote=punix:$DB_SOCK --remote=db:Open_vSwitch,Open_vSwitch,manager_options --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --pidfile=$DB_PIDFILE --detach $OVS_CONF_DB
$OVS_DIR/utilities/ovs-vsctl --no-wait --db=unix:$DB_SOCK init
$OVS_DIR/vswitchd/ovs-vswitchd unix:$DB_SOCK --pidfile=$VSD_PIDFILE --detach --log-file=$OVS_LOG --unixctl=$VSD_CTLSOCK
#$OVS_DIR/vswitchd/ovs-vswitchd unix:$DB_SOCK --pidfile=$VSD_PIDFILE --log-file=$OVS_LOG --unixctl=$VSD_CTLSOCK
