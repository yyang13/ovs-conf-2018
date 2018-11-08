#!/bin/bash

./stop-ovs-dpdk.sh
source $(dirname $0)/set-ovs-env.sh
source /home/yyang13/dpdk-env.sh
rm -rf $OVS_LOG
mkdir -p ${OVS_DIR}/etc/openvswitch
mkdir -p ${OVS_DIR}/var/run/openvswitch

#rmmod vxlan, vport-vxlan and openvswitch
/etc/init.d/openvswitch-switch stop

umount /run/hugepages/kvm
umount /dev/hugepages
mount -t hugetlbfs nodev /run/hugepages/kvm

modprobe uio
insmod $DPDK_BUILD/kmod/igb_uio.ko
sleep 1

ifconfig enp8s0f1 0 down
#$DPDK_DIR/usertools/dpdk-devbind.py --bind=igb_uio 0000:08:00.1
$DPDK_DIR/usertools/dpdk-devbind.py --bind=vfio-pci 0000:08:00.1
sleep 1

echo "start ovs dpdk"
rm -f $OVS_CONF_DB
$OVS_DIR/ovsdb/ovsdb-tool create $OVS_CONF_DB $OVS_DIR/vswitchd/vswitch.ovsschema
$OVS_DIR/ovsdb/ovsdb-server --unixctl=$DB_CTLSOCK --remote=punix:$DB_SOCK --remote=db:Open_vSwitch,Open_vSwitch,manager_options --private-key=db:Open_vSwitch,SSL,private_key --certificate=db:Open_vSwitch,SSL,certificate --bootstrap-ca-cert=db:Open_vSwitch,SSL,ca_cert --pidfile=$DB_PIDFILE --detach $OVS_CONF_DB
$OVS_DIR/utilities/ovs-vsctl --no-wait --db=unix:$DB_SOCK init

$OVS_DIR/utilities/ovs-vsctl --no-wait --db=unix:$DB_SOCK set Open_vSwitch . other_config:dpdk-init=true
#$OVS_DIR/utilities/ovs-vsctl --no-wait --db=unix:$DB_SOCK set Open_vSwitch . other_config:dpdk-socket-mem="1024,0"
#$OVS_DIR/utilities/ovs-vsctl --no-wait --db=unix:$DB_SOCK set Open_vSwitch . other_config:dpdk-socket-mem="-m 4096"
#$OVS_DIR/utilities/ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-lcore-mask="0f"
#$OVS_DIR/utilities/ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask="02"
$OVS_DIR/utilities/ovs-vsctl --no-wait --db=unix:$DB_SOCK set Open_vSwitch . other_config:dpdk-extra="--no-huge -m 4096"


$OVS_DIR/vswitchd/ovs-vswitchd unix:$DB_SOCK --pidfile=$VSD_PIDFILE --detach --log-file=$OVS_LOG --unixctl=$VSD_CTLSOCK
#$OVS_DIR/vswitchd/ovs-vswitchd unix:$DB_SOCK --pidfile=$VSD_PIDFILE --log-file=$OVS_LOG --unixctl=$VSD_CTLSOCK
