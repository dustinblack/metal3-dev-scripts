#!/bin/bash

for i in 0 1 2
do
  virsh attach-disk openshift_node_$i /home/osd$i.qcow2 vda --driver qemu --subdriver qcow2
done
  
