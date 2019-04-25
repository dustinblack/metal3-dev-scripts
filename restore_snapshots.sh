#!/bin/bash

if [ -z $1 ]
then
  echo "Suffix is required!"
  exit 1
else
  SUFFIX=$1
fi

VMS=$(virsh list --all | grep openshift | awk '{print $2}')
echo $VMS

for VM in $VMS
do
  virsh suspend $VM
done

for VM in $VMS
do
  virsh snapshot-revert $VM --snapshotname $VM-$SUFFIX --paused
  echo "Domain $VM set to snapshot $SUFFIX"
done

for VM in $VMS
do
  virsh resume $VM
done
