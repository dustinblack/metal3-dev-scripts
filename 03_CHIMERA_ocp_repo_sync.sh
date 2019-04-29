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

sync_go_repo_and_patch github.com/openshift-metalkube/kni-installer https://github.com/openshift-metalkube/kni-installer.git master
#sync_go_repo_and_patch github.com/openshift-metalkube/kni-installer https://github.com/openshift-metalkube/kni-installer.git 26894a5d8e19fde0d776abb0399b7cf6525972e9

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
sync_go_repo_and_patch github.com/operator-framework/operator-sdk https://github.com/operator-framework/operator-sdk.git master
#sync_go_repo_and_patch github.com/operator-framework/operator-sdk https://github.com/operator-framework/operator-sdk.git 3f9650c8088944b893516fb3175bf8b95843fe42

# Build operator-sdk
pushd "${GOPATH}/src/github.com/operator-framework/operator-sdk"
git checkout master
make dep
make install
popd

# Install baremetal-operator
sync_go_repo_and_patch github.com/metalkube/baremetal-operator https://github.com/metalkube/baremetal-operator.git master
#sync_go_repo_and_patch github.com/metalkube/baremetal-operator https://github.com/metalkube/baremetal-operator.git d1a26380780ed0a2068007a1440f5a239bdc626e
# FIXME(dhellmann): Use the pre-rename version of the operator until
# this repository is ready for the renamed version.
pushd $GOPATH/src/github.com/metalkube/baremetal-operator
git checkout origin/metalkube
popd


# Install rook repository
sync_go_repo_and_patch github.com/rook/rook https://github.com/rook/rook.git master

# Install ceph-mixin repository
sync_go_repo_and_patch github.com/ceph/ceph-mixins https://github.com/ceph/ceph-mixins.git master

# Install Kafka Strimzi repository
sync_go_repo_and_patch github.com/strimzi/strimzi-kafka-operator https://github.com/strimzi/strimzi-kafka-operator.git master

# Install Kafka Producer/Consumer repository
sync_go_repo_and_patch github.com/scholzj/kafka-test-apps https://github.com/scholzj/kafka-test-apps.git master

# Install web ui operator repository
sync_go_repo_and_patch github.com/kubevirt/web-ui-operator https://github.com/kubevirt/web-ui-operator master


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
export VERSION=$(curl -s https://github.com/kubevirt/containerized-data-importer/releases/latest | grep -o "v[0-9]\.[0-9]*\.[0-9]*")
wget https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml -O ~/metalshift-chimera/chimera-cdi/cdi-operator.yaml
wget https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator-cr.yaml -O ~/metalshift-chimera/chimera-cdi/cdi-operator-cr.yaml
