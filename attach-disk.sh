#!/bin/bash

echo Deleting old qcow2 images
rm -rf /home/osd*.qcow2

for i in 0 1 2
do
  echo Creating new qcow2 images
  qemu-img create -f qcow2 /home/osd$i.qcow2 50G
  echo Attaching disk to VM
  virsh attach-disk openshift_node_$i /home/osd$i.qcow2 vda --driver qemu --subdriver qcow2 --persistent --config  --live
done
  
