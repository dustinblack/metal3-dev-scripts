# Lab 01: Download and Prepare Components

> Note: To skip this lab, run the full 03 script:
```
./ORIG_03_ocp_repo_sync.sh
```

```
eval $(go env)
export CLONEPATH=$GOPATH/src/github.com
git clone https://github.com/openshift-metalkube/kni-installer.git $CLONEPATH/openshift-metalkube/kni-installer
git clone https://github.com/openshift-metalkube/facet.git $CLONEPATH/openshift-metalkube/facet
git clone https://github.com/operator-framework/operator-sdk.git $CLONEPATH/operator-framework/operator-sdk
git clone https://github.com/metalkube/baremetal-operator.git $CLONEPATH/metalkube/baremetal-operator
go get -v github.com/rakyll/statik
pushd "${CLONEPATH}/openshift-metalkube/facet"
yarn install
./build.sh
popd
pushd "${CLONEPATH}/operator-framework/operator-sdk"
make install
popd
```
