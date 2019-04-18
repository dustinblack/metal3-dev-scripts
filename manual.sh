#!/bin/bash

# run steps 01 to 05
./01_install_requirements.sh
./02_configure_host.sh
./03_ocp_repo_sync.sh
./04_CHIMERA_prep_ironic.sh 
./05_CHIMERA_build_ocp_installer.sh

# set up ironic
IRONIC_DATA_DIR=/opt/dev-scripts/ironic
mkdir -p $IRONIC_DATA_DIR/html/images
podman pod create -n ironic-pod
PODRUNCMD="podman run -d --net host --privileged -v ${IRONIC_DATA_DIR}:/shared --pod ironic-pod"
$PODRUNCMD --name dnsmasq --entrypoint /bin/rundnsmasq metalkube-ironic
$PODRUNCMD --name httpd --entrypoint /bin/runhttpd metalkube-ironic
$PODRUNCMD --name mariadb --entrypoint /bin/runmariadb --env MARIADB_PASSWORD=redhat metalkube-ironic
$PODRUNCMD --name ironic --env MARIADB_PASSWORD=redhat metalkube-ironic
$PODRUNCMD --name ironic-inspector metalkube-ironic-inspector

# create the cluster
sleep 30
./06_CHIMERA_create_cluster.sh
