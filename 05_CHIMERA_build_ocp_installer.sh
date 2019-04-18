#!/bin/bash

set -ex

source logging.sh
source common.sh

figlet "Building the Installer" | lolcat

eval "$(go env)"
echo "$GOPATH" | lolcat # should print $HOME/go or something like that

# Extend kni-installer timeouts
CREATEPATH="$GOPATH/src/github.com/openshift-metalkube/kni-installer/cmd/kni-install/create.go"
sed -i s/apiTimeout\ :=\ 30/apiTimeout\ :=\ 60/ $CREATEPATH
sed -i s/eventTimeout\ :=\ 60/eventTimeout\ :=\ 120/ $CREATEPATH
sed -i s/timeout\ :=\ 30/timeout\ :=\ 60/ $CREATEPATH
sed -i s/consoleRouteTimeout\ :=\ 10/consoleRouteTimeout\ :=\ 20/ $CREATEPATH

pushd "$GOPATH/src/github.com/openshift-metalkube/kni-installer"
export MODE=release
export TAGS="libvirt ironic"
./hack/build.sh
popd
