#!/bin/bash

set -ex
source logging.sh
source common.sh

eval "$(go env)"
echo "$GOPATH" | lolcat # should print $HOME/go or something like that

function sync_go_repo_and_patch {
    DEST="$GOPATH/src/$1"
    figlet "Syncing $1" | lolcat

    if [ ! -d $DEST ]; then
        mkdir -p $DEST
        git clone $2 $DEST
    fi

    pushd $DEST

    git am --abort || true
    git checkout $3
    git pull --rebase origin $3
    git branch -D we_dont_need_no_stinkin_patches || true
    git checkout -b we_dont_need_no_stinkin_patches

    shift 3
    for arg in "$@"; do
        curl -L $arg | git am
    done
    popd
}

#sync_go_repo_and_patch github.com/openshift-metalkube/kni-installer https://github.com/openshift-metalkube/kni-installer.git master
sync_go_repo_and_patch github.com/openshift-metalkube/kni-installer https://github.com/openshift-metalkube/kni-installer.git 1495d7ad68022bd365d98bf6ac846d9f132458bd

# FIXME(russellb) - disabled due to build failure related to metal3 rename
#sync_go_repo_and_patch github.com/openshift-metalkube/facet https://github.com/openshift-metalkube/facet.git master
#sync_go_repo_and_patch github.com/openshift-metalkube/facet https://github.com/openshift-metalkube/facet.git b940bfab4e38a93826eba6dd3d876d6907f1642c

# Build facet
#go get -v github.com/rakyll/statik
#pushd "${GOPATH}/src/github.com/openshift-metalkube/facet"
#yarn install
#./build.sh
#popd

mkdir -p $GOPATH/bin

# Install Go dependency management tool
# Using pre-compiled binaries instead of installing from source
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
export PATH="${GOPATH}/bin:$PATH"

# Install operator-sdk for use by the baremetal-operator
#sync_go_repo_and_patch github.com/operator-framework/operator-sdk https://github.com/operator-framework/operator-sdk.git master
sync_go_repo_and_patch github.com/operator-framework/operator-sdk https://github.com/operator-framework/operator-sdk.git 51d28df214440d97031368d7d700a2805161015d

# Build operator-sdk
pushd "${GOPATH}/src/github.com/operator-framework/operator-sdk"
git checkout master
make dep
make install
popd

# Install baremetal-operator
#sync_go_repo_and_patch github.com/metalkube/baremetal-operator https://github.com/metalkube/baremetal-operator.git master
sync_go_repo_and_patch github.com/metalkube/baremetal-operator https://github.com/metalkube/baremetal-operator.git efb07458b30f56060588b34d30c07cc83a81ea18
# FIXME(dhellmann): Use the pre-rename version of the operator until
# this repository is ready for the renamed version.
pushd $GOPATH/src/github.com/metalkube/baremetal-operator
git checkout origin/metalkube
popd


# Install rook repository
#sync_go_repo_and_patch github.com/rook/rook https://github.com/rook/rook.git master
sync_go_repo_and_patch github.com/rook/rook https://github.com/rook/rook.git 02a39db142c82ee897658e9783250b5ffa93f586

# Install ceph-mixin repository
#sync_go_repo_and_patch github.com/ceph/ceph-mixins https://github.com/ceph/ceph-mixins.git master
sync_go_repo_and_patch github.com/ceph/ceph-mixins https://github.com/ceph/ceph-mixins.git b3dab94ab438e2849238330e69fc3bd6105e1ed7

# Install Kafka Strimzi repository
#sync_go_repo_and_patch github.com/strimzi/strimzi-kafka-operator https://github.com/strimzi/strimzi-kafka-operator.git master
sync_go_repo_and_patch github.com/strimzi/strimzi-kafka-operator https://github.com/strimzi/strimzi-kafka-operator.git 280d6e3f3d0b080a953219004b04e529e53585d6

# Install Kafka Producer/Consumer repository
#sync_go_repo_and_patch github.com/scholzj/kafka-test-apps https://github.com/scholzj/kafka-test-apps.git master
sync_go_repo_and_patch github.com/scholzj/kafka-test-apps https://github.com/scholzj/kafka-test-apps.git 7463f3d9790229d70304805e327e58406e950f1e

# Install web ui operator repository
#sync_go_repo_and_patch github.com/kubevirt/web-ui-operator https://github.com/kubevirt/web-ui-operator master
sync_go_repo_and_patch github.com/kubevirt/web-ui-operator https://github.com/kubevirt/web-ui-operator 2c07db85eb0c6016e69ba710d7525e04406bdd0f


##FOR CHIMERA

# Copy the kubevirt tree and modify
DEMOPATH=/root/demo
mkdir -p $DEMOPATH
cp -a ${GOPATH}/src/github.com/kubevirt $DEMOPATH
UIVERSION="${UIVERSION:-v2.0.0-13.1}"
sed -i "s/okdvirt/openshiftvirt/" ${DEMOPATH}/kubevirt/web-ui-operator/deploy/crds/kubevirt_v1alpha1_kwebui_cr.yaml
sed -i "s/version: .*/version: \"$UIVERSION\"/" ${DEMOPATH}/kubevirt/web-ui-operator/deploy/crds/kubevirt_v1alpha1_kwebui_cr.yaml

# Get the virtctl binary downloaded to /usr/local/bin
wget https://github.com/kubevirt/kubevirt/releases/download/v0.15.0/virtctl-v0.15.0-linux-amd64 -O /usr/local/bin/virtctl 
chmod 755 /usr/local/bin/virtctl

# Get the CDI yaml files
mkdir -p ${DEMOPATH}/chimera-cdi
export VERSION=$(curl -s https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -o "v[0-9]\.[0-9]*\.[0-9]*")
wget https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml -O ${DEMOPATH}/chimera-cdi/cdi-operator.yaml
wget https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator-cr.yaml -O ${DEMOPATH}/chimera-cdi/cdi-operator-cr.yaml
