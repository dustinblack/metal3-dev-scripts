# Prepare Chimera Lab

You can do all of this (except the Red Hat subscription and repo stuff and creating the `config_root.sh` file) via the Makefile.

This will apply the yum packages and services and also run the lab pre-configure scripts:
```
make chimera_all
```

You can also just run the lab pre-configure scripts:
```
make chimera_lab_ready
```

## Operating Environment

* Have $loads of CPU and memory
* Install RHEL or CentOS 7.4+
* Give your host a FQDN
* For RHEL, register system and subscribe to _extras_ and _optional_ repos
* Install virtualization tools
* Enable libvirtd
* Install git (and vim-enhanced for convenience)

RHEL:
```
subscription-manager register
subscription-manager ...
subscription-manager repos --disable=*
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-optional-rpms
```

RHEL/CentOS:
```
yum -y groupinstall 'Virtualization Host'
systemctl enable libvirtd; systemctl start libvirtd
yum -y install git vim-enhanced
```

## Clone This Repo

```
git clone https://github.com/dustinblack/metalshift-chimera
cd metalshift-chimera
```

## Setup pull secret

> Note: `config_*.sh` is already in the `.gitignore` file.

Doing this here for the root user, but note that the scripts look for `config_${USER}.sh`

```
cp config_example.sh config_root.sh
```

Add your pull secret as noted in the script.

## Storage for images

You can mount storage to `/opt/dev-scripts` if you need separate storage space for virtual machine and container images.

## Run setup scripts

```
./01_install_requirements.sh
./02_configure_host.sh
./03_CHIMERA_ocp_repo_sync.sh
./04_CHIMERA_prep_ironic.sh 
./05_build_ocp_installer.sh
```

