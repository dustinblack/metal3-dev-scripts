# Deploy Ceph via Rook.io

<img src="https://landscape.cncf.io/logos/rook.svg" alt="Rook Logo" height="200px"><img src="https://ceph.com/wp-content/uploads/2016/07/Ceph_Logo_Stacked_RGB_120411_fa.png" alt="Ceph Logo" width="200px">

## Intro
[Rook.io](https://rook.io/) is a Kubernetes [operator](https://coreos.com/operators/) that orchestrates software-defined storage deployment and management for container persistent storage. We use rook.io initially to deploy [Ceph](https://ceph.com/) as a set of containerized services. Then we define a storage class, which the operator will "listen" to in order to automate the provisioning of Ceph volumes to fulfill persistent volume claims.

## Lab

We need to first run a cleanup script to ensure that any previous Ceph deployments in our lab don't cause problems.
```
chimera-rook/cleanup.sh
```

Login to the cluster.
```
export KUBECONFIG=/root/metalshift-chimera/ocp/auth/kubeconfig
oc login -u system:admin
```

We create a security context constraint and then deploy the rook.io operator.
```
oc create -f chimera-rook/scc.yaml 
oc create -f chimera-rook/operator.yaml 
```

Before we use the operator, let's ensure that its pods all start normally.
```
watch oc get pods -n rook-ceph-system
```

As that continues to start up, let's take a look at the YAML that will be used to create the Ceph cluster.
```
less chimera-rook/cluster.yaml
```

With the operator ready, we can deploy the Ceph cluster and the toolbox.
```
oc create -f chimera-rook/cluster.yaml 
oc create -f chimera-rook/toolbox.yaml 
```

The operator will respond to the cluster request by inventorying the environment, standing up the three requested Ceph mons and the Ceph manager, and then preparing and standing up the three Ceph OSDs. Our nodes are each configured with NVMe SSDs that will be used as the OSD devices.

Let's monitor the cluster pod deployments.
```
watch oc get pods -n rook-ceph
```

When the pods are all ready, we can use the toolbox pod as a convenient location for executing Ceph commands.
```
TOOLBOX=$(oc get pods -l app=rook-ceph-tools -n rook-ceph | grep -v NAME | awk '{print $1}')
oc exec -n rook-ceph $TOOLBOX -- ceph -s
oc exec -n rook-ceph $TOOLBOX -- ceph osd tree
```

We now create the storage class, which will be used by the rook.io operator to orchestrate the storage provisioning.
```
oc create -f chimera-rook/storageclass.yaml
```

Looking again at the `ceph -s` output, we can now see that a pool exists with the default 100 placement groups, and we can dig a little deeper into the configuraiton.
```
oc exec -n rook-ceph $TOOLBOX -- ceph -s
oc exec -n rook-ceph $TOOLBOX -- ceph df
oc exec -n rook-ceph $TOOLBOX -- ceph osd pool get rbd all
```

We'll test out our new persistent storage by making a simple persistent volume claim.
```
oc create -f chimera-rook/pvctest.yaml
oc get pvc
oc get pv
oc describe pv
```

The Ceph RBD has the same name as the OpenShift persistent volume.
```
PV=$(oc get pv | grep -v NAME | awk '{print $1}')
oc exec -n rook-ceph $TOOLBOX -- rbd ls
oc exec -n rook-ceph $TOOLBOX -- rbd info $PV
```

Cleanup our test PVC.
```
oc delete -f chimera-rook/pvctest.yaml
oc get pvc
oc get pv
```

## Lab Recording
TODO
