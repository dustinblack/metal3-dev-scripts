# Prepare Chimera Lab

<img src="images/chimera-logo.png" alt="Chimera Logo" width="200px">

## Operating Environment

* Have $loads of CPU and memory
* Install RHEL or CentOS 7.4+
* Enable VT-d (if you want to PCI-passthrough to VMs, which we need for Chimera)
* Give your host a FQDN
* For RHEL, register system and subscribe to _extras_ and _optional_ repos
* Install git

**RHEL:**
```
subscription-manager register
subscription-manager ...
subscription-manager repos --disable=*
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-optional-rpms
```

**RHEL/CentOS:**
```
yum -y install git
```

**Optional -- RHEL/CentOS VT-d:**
You'll need this if you want to do any PCI device passthrough.
First make sure this is enabled in your BIOS, then edit `/etc/default/grub` to add `intel_iommu=on` to the `GRUB_CMDLINE_LINUX` var. Then rebuild your grub config and reboot:
```
sed -i s/quiet/quiet\ intel_iommu\=on/ /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg 
init 6
```

## Clone This Repo

```
git clone https://github.com/dustinblack/metalshift-chimera
cd metalshift-chimera
```

## Setup pull secret

> Note: `config_*.sh` is already in the `.gitignore` file.

Doing this here for the root user, but note that the scripts look for `config_${USER}.sh`

> Note: We actually need a temporary shared pull secret for now, rather than the user-assigned one.

```
cp config_example.sh config_root.sh
```

Add your pull secret as noted in the script.

## Storage for images

You can mount storage to `/opt/dev-scripts` if you need separate space for virtual machine and container images.

## Passthrough NVMe for Chimera

We have some script hacks in place for the Chimera system specifically, which accounts for specific NVMe drives being available in specific PCIe slots. For this node to pass through the NVMe devices properly to the VMs, edit the `metalshift-chimera/tripleo-quickstart-config/metalkube-nodes.yml` to set `flavors.openshift_node.nvme_passthrough` to `true`.

## Storage qcow2 disks for Chimera

Another hack to use qcow2 disk images...

The passthrough NVMe above does not allow for VM snapshots. So for the Chimera demo lab where snapshots are required, the NVMe devices have been formatted and mounted with pre-defined qcow2 images (/nvme{1..4}n1/nvme{1..4}n1.qcow2). To use these disk images, edit the `metalshift-chimera/tripleo-quickstart-config/metalkube-nodes.yml` to set `flavors.openshift_node.attach_qcow2` to `true`. Then above for each of the `overcloud_node` entries, add the base nvme name, i.e. `nvme1n1`, to associate with each VM.

## Run setup scripts

```
make chimera_all
```

If you've already run this on the system before then the yum and libvirt stuff can be skipped.

```
make chimera_lab_ready
```

## Setup virtual storage domains
For the Chimera host when using the qcow2 storage disk images, we have each NVMe mounted and with a qcow2 file in it to virtualize the storage for the VMs in a way that is snapshottable. The libvirt subsystem needs to be informed about these.
```
for i in {1..4}; do virsh pool-create-as nvme${i}n1 dir --target /nvme${i}n1; done
systemctl restart libvirtd
```

## Remote network access

The simplest way to access the OCP network is to add physical interfaces to the _baremetal_ bridge. An external host connected to the bridged interface will then get DHCP assignments from the already-running dnsmasq for that network.

For the Chimera box, we need to add interfaces `enp7s0` and `enp12s0` to the bridge.

```
brctl addif baremetal enp7s0
brctl addif baremetal enp12s0
```

You may need to adjust `/etc/resolv.conf` on the connected host to move the 192.168.111.1 DNS server to the top of the list, or otherwise adjust your configuration so that name resolution on the OCP network functions.

## Add the Red Hat container registry pull secret
Part of the lab expects to pull images from the Red Hat container registry. This expects authentication via a secret names _rhsecret_. This will need to be created on the host system after OCP is deployed.

## VM images
The nginx server will be installed and customzed to serve from `/opt/dev-scripts/html` on port 88 via the `00_CHIMERA_prep_host.sh` script. Any VM images that will be loaded into the CDI DataVolumes will need to be placed here.
