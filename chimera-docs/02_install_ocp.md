# Demo 1: Install OpenShift 4

<img src="images/openshift_logo.png" alt="OpenShift Logo" height="200px"><img src="images/metal3_logo.png" alt="Metal3 Logo" height="200px">

## Intro

The OCP deployment process is heavily automated to leverage the underlying host, network, and Ironic structures we have previously provided. Below is a rough set of tasks that the installer will go through.

* Generate an install config
* Adjust host networking parameters
* Test Ironic
* Run [**kni-installer**](https://github.com/openshift-metalkube/kni-installer) to deploy the bootstrap and OCP VMs
* Configure [etcd](https://coreos.com/etcd/) cluster
* Taint the masters to make them schedulable

## Create the cluster

```
./06_CHIMERA_create_cluster.sh
```

## Demo Recording
TODO
