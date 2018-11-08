#!/bin/bash

	#-nographic \
/home/yyang13/qemu/x86_64-softmmu/qemu-system-x86_64  -smp 2 -m 4096 -enable-kvm -chardev socket,id=char0,path=/var/run/openvswitch/dpdkvhostuser1 \
    -netdev type=vhost-user,id=mynet1,chardev=char0 \
    -device virtio-net-pci,netdev=mynet1,mac=52:54:00:02:d9:00 \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::2222-:22 \
    -numa node,memdev=mem -mem-prealloc \
    -object memory-backend-file,id=mem,size=4096M,mem-path=/home/yyang13/vhost-workspace/tmpfs,share=on \
	-D qemu.log -monitor telnet::5552,server,nowait \
        -vnc :2 \
        -daemonize \
    ubuntu-16.04-server-cloudimg-amd64-disk1.img
