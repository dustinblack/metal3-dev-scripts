# Install OCP

## Build the installer

```
eval "$(go env)"
pushd "$GOPATH/src/github.com/openshift-metalkube/kni-installer"
export MODE=release
export TAGS="libvirt ironic"
./hack/build.sh
popd
```

## Create the cluster

```

```
