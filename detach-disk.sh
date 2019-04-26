#!/bin/bash

for i in 0 1 2
do
  virsh detach-disk openshift_node_$i /home/osd$i.qcow2 --persistent --config --live
done

