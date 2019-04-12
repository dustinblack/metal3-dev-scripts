# Braindump soup-to-nuts log of lab work

## Prerequisites

* $Loads of CPU and memory
* Start with a CentOS/RHEL 7.4+ host with virtualization tools.

```
# yum -y install git vim-enhanced
# yum -y groupinstall 'Virtualization Host'
# systemctl start libvirtd
```

## Clone repo

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

## Simplest no-edit deployment FYI

The Makefile is basically just a wrapper script to run the numbered shell scripts. So in the very simplest terms, you can:

```
# make
```

And that's it. :)

## Workshop Setup WIP

### Setup prerequisites for virtual host

The `install_requirements` script can be used as-is from the original *dev-scripts* repo.

```
# ./01_install_requirements.sh
```

### Setup virtual machines and ancillary requirements

The `configure_host` script will instantiate the "dummy" baremetal virtual machines. The `tripleo-quickstart-config/metalkube-nodes.yml`file is referenced by an ansible task here and has been modified in this repo to configure only 3 VMs, replace the "master" naming convention with "node" instead, and bump up the CPU and memory resources to account for hyperconvergence.

After the VMs are created, the script performs a number of tasks to prepare the virtual host system, and these can all be used as-is from the original *dev-scripts* repo.

```
# ./02_configure_host.sh
```

At this point, you should have 3 virtual machines created, but not running.

```
TODO add virsh command
```

TODO Revisit this section to likely add the physical hard drive / partition passthrough to the VMs for Rook.

### Workshop-ready state

I believe at this point we have the initial starting state for the workshop. The "dummy" baremetal VMs will represent the real hardware systems, so further tasks from this point should actually be part of the workshop itself.

## Workshop process WIP

### Initial deployment prep

The `ocp_repo_sync` begins to perform some of the fundamental deployment tasks. We'll need to go through this in detail. Some of it we may want to push up to the setup process in the sections above if it doesn't have particular value to demonstrate. Most of this will likely become the initial manual deployment tasks that are part of the workshop demonstration.

> Note: We probably don't need the strimzi/kafka stuff at all unless we decide to use those to demonstrate a workload. If so, they should probably be later in the process anyway.

### Ironic

The contents of `setup_ironic` will certainly be interesting to demonstrate, so we definitely won't run this script directly. The tasks here basically setup Ironic and its dependencies in local containers with podman. It will be a good chance to talk about:

* Podman vs. Docker
* Ironic and its relationship to OpenStack
* PXE booting
* Introspection

### Build OCP Installer

We need to play with this, but I'm curious if the `build_ocp_installer` script should just be moved earlier to our setup process, or if it is worth demonstrating. I don't immediatley see how it would have a dependency on `setup_ironic` and have to come after it.

### Create Cluster
