# Setup Ironic

```
IRONIC_DATA_DIR=/opt/dev-scripts/ironic
mkdir -p $IRONIC_DATA_DIR/html/images
podman pod create -n ironic-pod
PODRUNCMD="podman run -d --net host --privileged -v ${IRONIC_DATA_DIR}:/shared --pod ironic-pod"
$PODRUNCMD --name dnsmasq --entrypoint /bin/rundnsmasq metalkube-ironic
$PODRUNCMD --name httpd --entrypoint /bin/runhttpd metalkube-ironic
$PODRUNCMD --name mariadb --entrypoint /bin/runmariadb --env MARIADB_PASSWORD=redhat metalkube-ironic
$PODRUNCMD --name ironic --env MARIADB_PASSWORD=redhat metalkube-ironic
$PODRUNCMD --name ironic-inspector metalkube-ironic-inspector
```
