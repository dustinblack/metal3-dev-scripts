# Prepare Chimera Lab

## Operating Environment

* Have $loads of CPU and memory
* Install RHEL or CentOS 7.4+
* For RHEL, register system and subscribe to _extras_ and _optional_ repos
* Install virtualization tools
* Enable libvirtd
* Install git (and vim-enhanced for convenience)

RHEL:
```
# subscription-manager register
# subscription-manager ...
# subscription-manager repos --disable=*
# subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-optional-rpms
```

RHEL/CentOS:
```
# yum -y groupinstall 'Virtualization Host'
# systemctl enable libvirtd; systemctl start libvirtd
# yum -y install git vim-enhanced
```

## Clone This Repo

```
# git clone https://github.com/dustinblack/metalshift-chimera
# cd metalshift-chimera
```

## Setup pull secret

> Note: `config_*.sh` is already in the `.gitignore` file.

Doing this here for the root user, but note that the scripts look for `config_${USER}.sh`

```
# cp config_example.sh config_root.sh
```

Add your pull secret as noted in the script.

## Run setup scripts

```
# ./01_install_requirements.sh
# ./02_configure_host.sh
# ./03_WORKSHOP_go_dependency.sh
```
