#!/bin/bash

if [ -z $1 ]
then
  SUFFIX=snap-$(date +%F-%R)
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
  virsh snapshot-create-as --domain $VM --name $VM-$SUFFIX
done

for VM in $VMS
do
  virsh resume $VM
done 
