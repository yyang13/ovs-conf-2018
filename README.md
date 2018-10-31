OVS stuff for demo
==================

Requirements
------------
```
DPDK >= 18.05 (4K pages support, vhost-user interrupt mode)
OVS >= 2.9 (vdev support)
qemu >= 2.5
UIO driver must be vfio-pci (modprobe vfio-pci)
VT-d must be supported and enabled in your hardware platform
IOMMU must be enabled (iommu=pt intel_iommu=on)
```

Patch for OVS 2.10.0
--------------------
```
0001-Patch-for-OVS-conference-2018-demo.patch
```

How to use normal 4K pages
--------------------------
```
$ sudo ovs-vsctl set Open_vSwitch . other_config:dpdk-extra="--no-huge -m 4096"
```

How to add DPDK vdev port for vhost-user interface
--------------------------------------------------
```
sudo ovs-vsctl add-port br-int dpdkvhostuser1 -- set Interface dpdkvhostuser1 type=dpdk options:dpdk-devargs=net_vhost0,iface=/var/run/openvswitch/dpdkvhostuser1,queues=1

sudo ovs-vsctl add-port br-int dpdkvhostuser2 -- set Interface dpdkvhostuser2 type=dpdk options:dpdk-devargs=net_vhost1,iface=/var/run/openvswitch/dpdkvhostuser2,queues=1

```

How to start VM
---------------
```
sudo qemu-system-x86_64  -smp 2 -m 4096 -enable-kvm -chardev socket,id=char0,path=/var/run/openvswitch/dpdkvhostuser1 \
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

Notes: /home/yyang13/vhost-workspace/tmpfs is tmpfs
```

Demo Topology
-------------
![Demo Topology](https://raw.githubusercontent.com/yyang13/ovs-conf-2018/master/demo-topo.gif)
