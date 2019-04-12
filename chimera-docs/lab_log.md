# Braindump soup-to-nuts log of lab work

## Prerequisites

* $Loads of CPU and memory
* Start with a CentOS/RHEL 7.4+ host with virtualization tools.

```
# yum -y install git vim-enhanced
# yum -y groupinstall 'Virtualization Host'
# systemctl start libvirtd
```

### RHEL

If running RHEL instead of CentOS, enable the _extras_ and _optional_ repos.

```
# subscription-manager repos --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-optional-rpms
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

### Pull container images 

```
podman image pull quay.io/metalkube/metalkube-ironic
podman image pull quay.io/metalkube/metalkube-ironic-inspector
```

### Setup prerequisites for virtual host

The `01_install_requirements.sh` script can be used as-is from the original *dev-scripts* repo.

```
# ./01_install_requirements.sh
```

### Setup virtual machines and ancillary requirements

The `02_configure_host.sh` script will instantiate the "dummy" baremetal virtual machines. The `tripleo-quickstart-config/metalkube-nodes.yml`file is referenced by an ansible task here and has been modified in this repo to configure only 3 VMs, replace the "master" naming convention with "node" instead, and bump up the CPU and memory resources to account for hyperconvergence.

After the VMs are created, the script performs a number of tasks to prepare the virtual host system, and these can all be used as-is from the original *dev-scripts* repo.

```
# ./02_configure_host.sh
```

At this point, you should have 3 virtual machines created, but not running.

```
# virsh list --all
 Id    Name                           State
----------------------------------------------------
 -     openshift_node_0               shut off
 -     openshift_node_1               shut off
 -     openshift_node_2               shut off
```

TODO Revisit this section to likely add the physical hard drive / partition passthrough to the VMs for Rook.

### Initial deployment prep

The original `03_ocp_repo_sync.sh` script begins to perform some of the fundamental deployment tasks. Most of the tasks here we will want to do manually as part of the hands-on lab. For the workshop, the `03_CHIMERA_go_dependency.sh` script has been thinned down to replace the original `03` script.

```
# ./03_CHIMERA_go_dependency.sh
```

> Note: We probably don't need the strimzi/kafka stuff at all unless we decide to use those to demonstrate a workload. If so, they should probably be later in the process anyway.

### Ironic image prep

TODO Decide if we will do this here via script or manually in a lab.

```
# ./04_CHIMERA_prep_ironic.sh
```

### Workshop-ready state

I believe at this point we have the initial starting state for the workshop. The "dummy" baremetal VMs will represent the real hardware systems, so further tasks from this point should actually be part of the workshop itself.

## Workshop process WIP

### Phase 1: Download and install components

Stuff from the original `03` script that we'll probably use at this point in the lab guide:

```
# eval $(go env)
# export CLONEPATH=$GOPATH/src/github.com
# git clone https://github.com/openshift-metalkube/kni-installer.git $CLONEPATH/openshift-metalkube/kni-installer
# git clone https://github.com/openshift-metalkube/facet.git $CLONEPATH/openshift-metalkube/facet
# git clone https://github.com/operator-framework/operator-sdk.git $CLONEPATH/operator-framework/operator-sdk
# git clone https://github.com/metalkube/baremetal-operator.git $CLONEPATH/metalkube/baremetal-operator
>>WIP
# go get -v github.com/rakyll/statik
# pushd "${CLONEPATH}/openshift-metalkube/facet"
# yarn install
# ./build.sh
# popd
# pushd "${CLONEPATH}/operator-framework/operator-sdk"
# #git checkout master
# #make dep
# make install
# popd
<<WIP
```

### Phase 2: Setup Ironic

The contents of `04_setup_ironic.sh` will certainly be interesting to demonstrate, so we definitely won't run this script directly. The tasks here basically setup Ironic and its dependencies in local containers with podman. It will be a good chance to talk about:

* Podman vs. Docker
* Ironic and its relationship to OpenStack
* PXE booting
* Introspection

The beginning section of the script pulls down some necessary images for Ironic to use for provisioning.

TODO: Decide if we should do this image pulling as part of the prep work or as part of the lab. For now, it is added to the prep work above.

Trying to minimize the steps:
```
>>>WIP
mariadb_password=$(echo $(date;hostname)|sha256sum |cut -c-20)
IRONIC_DATA_DIR="/opt/dev-scripts/ironic"
IRONIC_IMAGE="metalkube-ironic"
IRONIC_INSPECTOR_IMAGE="metalkube-ironic-inspector"
mkdir -p "$IRONIC_DATA_DIR/html/images"
podman pod create -n ironic-pod
podman run -d --net host --privileged --name dnsmasq  --pod ironic-pod \
     -v $IRONIC_DATA_DIR:/shared --entrypoint /bin/rundnsmasq ${IRONIC_IMAGE}
podman run -d --net host --privileged --name httpd --pod ironic-pod \
     -v $IRONIC_DATA_DIR:/shared --entrypoint /bin/runhttpd ${IRONIC_IMAGE}
podman run -d --net host --privileged --name mariadb --pod ironic-pod \
     -v $IRONIC_DATA_DIR:/shared --entrypoint /bin/runmariadb \
     --env MARIADB_PASSWORD=$mariadb_password ${IRONIC_IMAGE}
podman run -d --net host --privileged --name ironic --pod ironic-pod \
     --env MARIADB_PASSWORD=$mariadb_password \
     -v $IRONIC_DATA_DIR:/shared ${IRONIC_IMAGE}
podman run -d --net host --privileged --name ironic-inspector --pod ironic-pod "${IRONIC_INSPECTOR_IMAGE}"
<<<WIP
```

### Build OCP Installer

Simple steps pulled from the `05_build_ocp_installer.sh` script:

```
# eval "$(go env)"
# pushd "$GOPATH/src/github.com/openshift-metalkube/kni-installer"
# export MODE=release
# export TAGS="libvirt ironic"
# ./hack/build.sh
# popd
```


### Create Cluster

## TODOs

* Create a lab cleanup script that will revert the host node back to a clean state.
