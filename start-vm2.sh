#!/bin/bash

	#-nographic \
/home/yyang13/qemu/x86_64-softmmu/qemu-system-x86_64  -smp 2 -m 4096 -enable-kvm -chardev socket,id=char1,path=/var/run/openvswitch/dpdkvhostuser2 \
    -netdev type=vhost-user,id=mynet2,chardev=char1 \
    -device virtio-net-pci,netdev=mynet2,mac=52:54:00:02:d9:01 \
    -net nic,model=virtio \
    -net user,hostfwd=tcp::2223-:22 \
    -numa node,memdev=mem2 -mem-prealloc \
    -object memory-backend-file,id=mem2,size=4096M,mem-path=/home/yyang13/vhost-workspace/tmpfs2,share=on \
	-D qemu2.log -monitor telnet::5553,server,nowait \
        -vnc :3 \
        -daemonize \
    ubuntu-16.04-server-cloudimg-amd64-disk2.img
