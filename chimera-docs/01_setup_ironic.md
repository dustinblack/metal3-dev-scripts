# Setup Ironic

<img src="https://avatars1.githubusercontent.com/u/35034937?s=400&v=4" alt="Ironic Logo" width="200px"><img src="https://media.mastodon.at/system/media_attachments/files/001/553/566/original/f0ee34263aa771be.png" alt="Podman Logo" width="200px">

## Intro

The [Ironic](https://wiki.openstack.org/wiki/Ironic) component of OpenStack is leveraged to bootstrap baremetal nodes into an OpenShift-ready operating environment. We run Ironic and its dependencies as containers on the deployment host via [podman](https://podman.io/).

> Note: As part of preparing this lab environment, we have previously pulled down both the Ironic container images the Red Hat CoreOS machine images onto this deployment host.

## Lab

First, let's set our variables. The `$IRONIC_DATA_DIRECTORY` is mounted into the containers and it hosts the machine image files that will be used to setup the operating environments on the baremetal nodes. We point this locally to where we have previously downloaded the images and other Ironic metadata.
```
IRONIC_DATA_DIR=/opt/dev-scripts/ironic
```

Our `podman` command is lengthy, so we'll instantiate a variable for convenience.
```
PODRUNCMD="podman run -d --net host --privileged -v ${IRONIC_DATA_DIR}:/shared --pod ironic-pod"
```

Finally, we create our local pod and the Ironic and dependency containers.
```
podman pod create -n ironic-pod
$PODRUNCMD --name dnsmasq --entrypoint /bin/rundnsmasq quay.io/metalkube/metalkube-ironic
$PODRUNCMD --name httpd --entrypoint /bin/runhttpd quay.io/metalkube/metalkube-ironic
$PODRUNCMD --name mariadb --entrypoint /bin/runmariadb --env MARIADB_PASSWORD=redhat quay.io/metalkube/metalkube-ironic
$PODRUNCMD --name ironic --env MARIADB_PASSWORD=redhat quay.io/metalkube/metalkube-ironic
$PODRUNCMD --name ironic-inspector quay.io/metalkube-ironic-inspector
```
