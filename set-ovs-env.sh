#!/bin/bash

DPDK_DIR=/home/yyang13/dpdk
DPDK_TARGET=x86_64-native-linuxapp-gcc
DPDK_BUILD=$DPDK_DIR/$DPDK_TARGET

OVS_DIR=/home/yyang13/ovs-for-demo
OVS_LOG=${OVS_DIR}/ovs.log
OVS_CONF_DB=/etc/openvswitch/conf.db
DB_PID=$(pidof ovsdb-server)
DB_PIDFILE=/var/run/openvswitch/ovsdb-server.pid
DB_CTLSOCK=/var/run/openvswitch/ovsdb-server.${DB_PID}.ctl
DB_SOCK=/var/run/openvswitch/ovsdb-server.${DB_PID}

VSD_PID=$(pidof ovs-vswitchd)
VSD_PIDFILE=/var/run/openvswitch/ovs-vswitchd.pid
VSD_CTLSOCK=/var/run/openvswitch/ovs-vswitchd.%{VSD_PID}.ctl
