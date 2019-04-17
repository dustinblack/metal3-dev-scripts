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

sync_go_repo_and_patch github.com/openshift-metalkube/kni-installer https://github.com/openshift-metalkube/kni-installer.git 0447ab1fa360139aef298a1a8bc17fdf6302caec

sync_go_repo_and_patch github.com/openshift-metalkube/facet https://github.com/openshift-metalkube/facet.git b940bfab4e38a93826eba6dd3d876d6907f1642c

# Build facet
go get -v github.com/rakyll/statik
pushd "${GOPATH}/src/github.com/openshift-metalkube/facet"
yarn install
./build.sh
popd

# Install Go dependency management tool
# Using pre-compiled binaries instead of installing from source
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
export PATH="${GOPATH}/bin:$PATH"

# Install operator-sdk for use by the baremetal-operator
sync_go_repo_and_patch github.com/operator-framework/operator-sdk https://github.com/operator-framework/operator-sdk.git 6767e9a70b967903db010cf1a3cf9a91cb974731

# Build operator-sdk
pushd "${GOPATH}/src/github.com/operator-framework/operator-sdk"
git checkout master
make dep
make install
popd

# Install baremetal-operator
sync_go_repo_and_patch github.com/metalkube/baremetal-operator https://github.com/metalkube/baremetal-operator.git 13eda9d3e95b43d135810ec3b115e0ecce8f60f6

# Install rook repository
sync_go_repo_and_patch github.com/rook/rook https://github.com/rook/rook.git master

# Install Kafka Strimzi repository
sync_go_repo_and_patch github.com/strimzi/strimzi-kafka-operator https://github.com/strimzi/strimzi-kafka-operator.git master

# Install Kafka Producer/Consumer repository
sync_go_repo_and_patch github.com/scholzj/kafka-test-apps https://github.com/scholzj/kafka-test-apps.git master

# Install web ui operator repository
sync_go_repo_and_patch github.com/kubevirt/web-ui-operator https://github.com/kubevirt/web-ui-operator master
