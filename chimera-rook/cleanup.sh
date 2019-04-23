#!/bin/bash

INVENTORY=$(virsh net-dhcp-leases baremetal | grep node | grep 192 | awk '{print $5}' | awk -F/ '{print $1}')
DISK="/dev/vda"
COMMANDS="sudo rm -rf /var/lib/rook; sudo sgdisk --zap-all $DISK; ls /dev/mapper/ceph-* | sudo xargs -I% -- dmsetup remove %; sudo rm -rf /dev/ceph-*"
for i in $INVENTORY; do
  echo "Cleaning up $i..."
  ssh -o "StrictHostKeyChecking=no" core@$i "$COMMANDS"
done

